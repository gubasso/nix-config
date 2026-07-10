#!/usr/bin/env bash
# dctl nix bootstrap — runs as the non-root remoteUser in onCreateCommand.
#
# Model: BOTH the /nix store (volume dctl-nix-store) AND the per-user Nix state
# (volume dctl-nix-state at ~/.local/state/nix, the XDG state dir) are PERSISTENT.
# So the store, db, profiles, generations and the `nix` binary all survive a
# container recreate. Nix is installed ONCE (first create); later recreates just
# re-source the profile. $HOME is otherwise ephemeral and the onCreate shell
# exports neither USER nor XDG_* (they are set as image ENV); ~/.bashrc is not
# read here, so we source the profile.d script by absolute path.
#
# Single-user (daemonless): official installer with --no-daemon. /nix is pre-owned
# by the user in the image, so no root/sudo is needed (our sudo is zypper-only).
# The Determinate --init none variant is multi-user-without-daemon and needs root
# — do not use it here.
#
# See dctl/nix-devcontainers.md (in the dotfiles repo) for the full design.
set -euo pipefail

# Belt-and-suspenders in case the image ENV is ever missing: the upstream
# profile.d script guards `export PATH` on $USER and derives the profile link
# from $XDG_STATE_HOME, so both must be set for nix to land on PATH.
export USER="${USER:-$(id -un)}"
export HOME="${HOME:-$(getent passwd "$USER" | cut -d: -f6)}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# (1) Load Nix if it is already present (persisted state volume); else install
#     once. XDG profile path first, legacy ~/.nix-profile as a fallback.
load_nix() {
  for f in "$XDG_STATE_HOME/nix/profile/etc/profile.d/nix.sh" \
    "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    # shellcheck source=/dev/null
    [ -e "$f" ] && {
      . "$f"
      break
    }
  done
  command -v nix >/dev/null 2>&1
}

if ! load_nix; then
  echo "==> Installing single-user Nix (XDG state on persistent volume)..."
  sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) \
    --no-daemon --yes --no-channel-add --no-modify-profile
  load_nix || true
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "==> ERROR: nix not on PATH after install." >&2
  echo "    USER=$USER HOME=$HOME XDG_STATE_HOME=$XDG_STATE_HOME" >&2
  ls -ld "$XDG_STATE_HOME/nix/profile/bin" "$HOME/.nix-profile/bin" 2>&1 | sed 's/^/    /' >&2
  exit 1
fi

# (2) Install/refresh the pinned dctl global toolset. It persists on the state
#     volume, so a plain "is it installed?" guard would never pick up a change
#     from a rebuilt image. Stamp the baked flake's IDENTITY on the /nix volume
#     and `nix profile upgrade` when it changes (weekly-rebuild refresh). Hash
#     flake.nix AND flake.lock: editing the package set (e.g. dropping a global
#     CLI like pre-commit) changes flake.nix but not the lock, and must still
#     trigger a refresh — a lock-only stamp would silently miss it.
FLAKE_DIR=/opt/dctl/global-flake
STAMP=/nix/var/dctl-global-flake.sha256 # on the persistent /nix volume
want="$(cat "$FLAKE_DIR/flake.nix" "$FLAKE_DIR/flake.lock" | sha256sum | cut -d' ' -f1)"
if ! nix profile list 2>/dev/null | grep -q 'dctl-global'; then
  echo "==> Installing dctl global toolset (nix profile add)..."
  nix profile add /opt/dctl/global-flake#default
  printf '%s\n' "$want" >"$STAMP"
elif [ "$want" != "$(cat "$STAMP" 2>/dev/null)" ]; then
  echo "==> flake.lock changed — refreshing dctl global toolset (nix profile upgrade)..."
  if nix profile upgrade --all; then
    printf '%s\n' "$want" >"$STAMP"
  else
    echo "==> WARNING: nix profile upgrade failed; will retry on next create." >&2
  fi
fi

echo "==> dctl nix bootstrap complete."
