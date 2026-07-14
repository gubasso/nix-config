# shellcheck shell=sh
# Baked into the agents image as /etc/profile.d/00-dctl-nix.sh.
# Put single-user Nix on PATH for LOGIN shells (bash -l / bash -lc), which
# covers dctl's non-interactive lifecycle hooks and `dctl ws run` — the mounted
# ~/.bashrc bails out early for non-interactive shells, so its rc.d/01-nix.bash
# fragment (which handles the interactive `dctl ws shell` case) does not run here.
# XDG profile (use-xdg-base-directories → ~/.local/state/nix/profile) first, then
# the legacy ~/.nix-profile as a fallback.
for f in \
  "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/etc/profile.d/nix.sh" \
  "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
  if [ -e "$f" ]; then
    # shellcheck source=/dev/null
    . "$f"
    break
  fi
done
