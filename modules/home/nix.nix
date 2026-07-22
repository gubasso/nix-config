# Nix client settings for standalone (non-NixOS) Home Manager hosts.
#
# On a NixOS host the system's /etc/nix/nix.conf owns experimental-features, and
# home-manager runs as a NixOS module with `osConfig` bound to the system config
# (non-null). There we skip this to avoid a redundant user-level nix.conf and
# pulling `nix` into the user profile. On a standalone host `osConfig` is null,
# so we generate ~/.config/nix/nix.conf to enable flakes — the client would
# otherwise reject `nix-command`/`flakes` entirely.
#
# We also establish the XDG base-directory layout as the single convention for
# standalone Nix: the per-user profile lives at ~/.local/state/nix/profile, not
# ~/.nix-profile. Beyond relocating Nix's own state, this flips `nix.useXdg`,
# which is what makes Home Manager's read-only `home.profileDirectory` resolve to
# the XDG profile (modules/home-environment.nix) instead of the (now absent)
# ~/.nix-profile. That in turn makes the generic-linux bash init source
# hm-session-vars.sh — and therefore FZF_DEFAULT_OPTS and every other session
# variable — from the correct path. Setting `use-xdg-base-directories` (rather
# than `nix.assumeXdg`) is the supported lever here because `nix.enable` is true:
# Home Manager asserts the two are mutually exclusive.
{
  lib,
  pkgs,
  osConfig ? null,
  ...
}:

lib.mkIf (osConfig == null) {
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
    };
  };
}
