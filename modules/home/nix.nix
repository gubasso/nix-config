# Nix client settings for standalone (non-NixOS) Home Manager hosts.
#
# On a NixOS host the system's /etc/nix/nix.conf owns experimental-features, and
# home-manager runs as a NixOS module with `osConfig` bound to the system config
# (non-null). There we skip this to avoid a redundant user-level nix.conf and
# pulling `nix` into the user profile. On a standalone host `osConfig` is null,
# so we generate ~/.config/nix/nix.conf to enable flakes — the client would
# otherwise reject `nix-command`/`flakes` entirely.
{
  lib,
  pkgs,
  osConfig ? null,
  ...
}:

lib.mkIf (osConfig == null) {
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
