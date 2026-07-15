# Base layer for AI agent sandboxing — "full pure-nix" toolchain model.
# See: docs/ARCHITECTURE.md and dctl/nix-devcontainers.md (in the dotfiles repo).
#
# Package-management boundary (only two managers, no curl-pipe installers):
#   - zypper (root): system/ABI/build libs + bootstrap only (curl, xz, git,
#     direnv). direnv is baked so the mounted shell rc hook can auto-activate
#     project devShells before Nix is bootstrapped.
#   - Nix (single-user, daemonless) on persistent /nix (store) + ~/.local/state/nix
#     (XDG per-user state) volumes: ALL user CLIs. A pinned "dctl global toolset"
#     flake (agent CLIs + shell UX + linters) is installed once by
#     /opt/dctl/nix-bootstrap.sh, invoked from the `nix`
#     devcontainer layer's onCreateCommand. Per-project language toolchains
#     (node/python/rust/zig) come from each project's own flake devShell,
#     auto-activated by direnv on `cd` / shell entry.

# Base image: opensuse/tumbleweed is the rolling release. Docker Hub's tag
# is rebuilt frequently against the current snapshot and mirrors sync
# atomically per snapshot, so the chronic mirror-lag 404s that plague
# Leap 16.0's image don't occur here. Tumbleweed's recommended upgrade
# command is `zypper dist-upgrade` (not `zypper update`).
#   https://en.opensuse.org/Portal:Tumbleweed
# hadolint ignore=DL3006
FROM opensuse/tumbleweed

ENV LANG=C.UTF-8
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Defence-in-depth against transient mirror 404s: disable libzypp's parallel
# package preload so a single mirror miss doesn't abort the whole transaction
# — standard sequential download falls back to the master.
#   https://www.suse.com/support/update/announcement/2025/suse-ru-202520488-1/
ENV ZYPP_PCK_PRELOAD=0

# System/ABI/build libs + bootstrap tooling ONLY. Interactive user CLIs
# (ripgrep, fd, bat, jq, tree, htop, neovim, gh, …) come from the Nix global toolset.
#   - direnv: used by the mounted shell rc hook to auto-activate project
#     devShells; must exist before Nix is bootstrapped.
#   - curl + xz: required by the single-user Nix installer.
# Package names follow openSUSE conventions. Verify availability with:
#   docker run --rm opensuse/tumbleweed bash -c "zypper --non-interactive refresh && zypper info <pkg>"
# clang-devel/llvm-devel are unversioned metapackages — they pull whatever
# LLVM major version is current in the snapshot.
# Retry loop: defence in depth against transient mirror flaps. Up to 3
# attempts with -f metadata refresh between retries.
# hadolint ignore=DL3035,DL3037
RUN zypper --non-interactive --gpg-auto-import-keys refresh -f \
    && zypper --non-interactive --gpg-auto-import-keys dist-upgrade --no-recommends --auto-agree-with-licenses --allow-vendor-change \
    && for attempt in 1 2 3; do \
        echo "==> Installing zypper packages (attempt ${attempt}/3)..." \
        && zypper --non-interactive install --no-recommends \
            ca-certificates \
            ca-certificates-mozilla \
            curl \
            xz \
            git-core \
            unzip \
            which \
            direnv \
            sudo \
            openssh-clients \
            rsync \
            stow \
            osc \
            build \
            kitty-terminfo \
            gcc \
            gcc-c++ \
            make \
            scdoc \
            binutils \
            glibc-devel \
            libffi-devel \
            libopenssl-3-devel \
            pkgconf-pkg-config \
            clang-devel \
            llvm-devel \
            dbus-1-devel \
        && break \
        || if [ "$attempt" -lt 3 ]; then \
            echo "==> Attempt ${attempt}/3 failed — refreshing mirrors and retrying in 5s..."; \
            sleep 5; \
            zypper --non-interactive --gpg-auto-import-keys refresh -f; \
        else \
            echo "==> ERROR: zypper install failed after 3 attempts"; exit 1; \
        fi; \
    done \
    && zypper clean --all

# Non-root user with package-management-only passwordless sudo
# USERNAME must match host $USER for config file consistency
# (sudo intentionally restricted to /usr/bin/zypper — agents and devcontainer
# features can still install packages, but the agent cannot run arbitrary
# commands as root)
ARG USERNAME
ARG USER_UID=1000
ARG USER_GID=1000

RUN test -n "$USERNAME" || { echo "USERNAME build arg is required"; exit 1; } \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && rm -f /home/$USERNAME/.bashrc /home/$USERNAME/.bash_logout /home/$USERNAME/.profile \
    && echo "$USERNAME ALL=(root) NOPASSWD: /usr/bin/zypper" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Pre-create directories for mounts
RUN install -d -m 0700 -o $USERNAME -g $USERNAME /home/$USERNAME/.ssh

# Pre-create parent dirs for personal bind mounts so Docker doesn't
# auto-create them as root:root and break writes from the non-root user.
#
# Docker auto-creates any missing parent of a bind-mount target as
# root:root 0755 at container startup, before the non-root remoteUser
# runs. That breaks anything writing under those parents from the non-root
# user (for example, bind-mounted tooling or config writing back to $HOME).
# Creating them here while still root fixes ownership once.
#
# /home/$USERNAME/.local/lib
#   Required by the claude-session bind mount declared in
#   devcontainer/agents/devcontainer.json
#   (target ${localEnv:HOME}/.local/lib/claude-session).
# /home/$USERNAME/.local/state/nix
#   Mount point for the dctl-nix-state named volume (the XDG per-user Nix state:
#   profile, generations, and the ~/.local/state/nix/profile convenience symlink).
#   Pre-owned so the fresh named volume inherits non-root ownership on first mount
#   — same rule as /nix below; a root-first-write is unrecoverable (zypper-only sudo).
#
# direnv config (~/.config/direnv) is NOT pre-created here: it is a read-only
# bind mount from the host (base devcontainer layer, host-is-SoT), which overlays
# the target — same as ~/.config/git, which also needs no pre-create.
#
RUN install -d -m 0755 -o $USERNAME -g $USERNAME \
        /home/$USERNAME/.local/lib \
        /home/$USERNAME/.local/state/nix \
        /home/$USERNAME/.config/osc

# Pre-create the cargo cache mount targets so the rust layer's named volumes
# inherit non-root ownership on first mount.
#
# The `rust` devcontainer layer (devcontainer/rust/devcontainer.json) mounts
# fresh named volumes at ~/.cargo/registry and ~/.cargo/git. In this pure-nix
# image nothing installs cargo/rustup at build time (Rust comes from each
# project's flake devShell), so ~/.cargo never exists in the image. Docker then
# fabricates the missing parent ~/.cargo — and the empty volume roots — as
# root:root before dropping to the non-root user, leaving cargo unable to write
# its registry cache (which breaks, e.g., building a ripsecrets pre-commit hook).
# A root-first-write is unrecoverable from inside (sudo is zypper-only), so
# pre-own the parent and the two mount targets here — same rule as /nix and the
# XDG Nix state above.
RUN install -d -m 0755 -o $USERNAME -g $USERNAME \
        /home/$USERNAME/.cargo \
        /home/$USERNAME/.cargo/registry \
        /home/$USERNAME/.cargo/git

# fzf-tab-completion: bash Tab completion via fzf (installed from upstream repo)
# Checked first by bash/.config/bash/rc.d/10-fzf.bash. The fzf binary itself
# comes from the Nix global toolset; this is just the completion glue.
RUN git clone --depth=1 https://github.com/lincheney/fzf-tab-completion /usr/share/fzf-tab-completion \
    && rm -rf /usr/share/fzf-tab-completion/.git \
    && test -r /usr/share/fzf-tab-completion/bash/fzf-bash-completion.sh

# --- Nix single-user store + config -----------------------------------------
# The store itself lives on a persistent named volume mounted at /nix (declared
# in the `nix` devcontainer layer). Pre-own /nix so a FRESH empty volume
# inherits non-root ownership on first mount — that lets nix-bootstrap.sh do a
# daemonless install with no root (our sudo is zypper-only, so a mis-owned
# volume is unrecoverable from inside; get this right).
RUN mkdir -m 0755 /nix && chown "${USER_UID}:${USER_GID}" /nix

# The upstream Nix profile.d script guards `export PATH` on $USER, and derives the
# profile link from $XDG_STATE_HOME; the onCreate shell exports neither. Set them
# at image level so onCreate, login, and interactive shells all put nix on PATH,
# and so Nix's C++ core and the profile.d script agree on the profile location
# (avoids the documented use-xdg split-brain). With use-xdg-base-directories the
# per-user Nix tree lives under ~/.local/state/nix (the persistent dctl-nix-state
# volume) — profile, generations, and the ~/.local/state/nix/profile symlink.
ENV USER=$USERNAME \
    XDG_CONFIG_HOME=/home/$USERNAME/.config \
    XDG_STATE_HOME=/home/$USERNAME/.local/state \
    XDG_CACHE_HOME=/home/$USERNAME/.cache

# Single-user nix.conf: empty build-users-group (no nixbld group), openSUSE
# ca-bundle fix, binary caches.
COPY nix.conf /etc/nix/nix.conf

# Put single-user Nix on PATH for LOGIN shells (dctl lifecycle hooks + ws run);
# the interactive `ws shell` case is handled by the mounted rc.d/01-nix.bash.
COPY profile-nix.sh /etc/profile.d/00-dctl-nix.sh

# Global toolset flake + idempotent bootstrap (run from onCreateCommand).
COPY nix-bootstrap.sh /opt/dctl/nix-bootstrap.sh
COPY global-flake /opt/dctl/global-flake
RUN chmod 0755 /opt/dctl/nix-bootstrap.sh
# Fail fast (clear message) if the pinned lock is missing — the in-image flake
# dir is read-only, so `nix profile add` could not lock at create-time.
RUN test -f /opt/dctl/global-flake/flake.lock \
    || { echo "ERROR: global-flake/flake.lock missing. Run 'nix flake lock' in"; \
         echo "       images/agents/global-flake/ on a host with Nix, then rebuild."; \
         exit 1; }

# direnv config (direnv.toml + direnvrc) is NOT baked here — it is bind-mounted
# read-only from the host's ~/.config/direnv by the base devcontainer layer, so
# there is a single source of truth (home/apps/direnv/). The mount is present from
# container start, before nix-bootstrap, so early auto-activation still works.

# Default editor (neovim comes from the Nix global toolset)
ENV EDITOR=nvim
ENV VISUAL=nvim

USER $USERNAME
WORKDIR /workspaces

CMD ["sleep", "infinity"]
