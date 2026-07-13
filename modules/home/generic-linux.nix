# Non-NixOS (generic Linux) enablement for standalone Home Manager hosts.
# Self-gates on `osConfig == null` (the standalone-HM signal, same gate as
# env-shell.nix); a no-op on NixOS, where the system already provides all of this.
#
# - targets.genericLinux.enable: Home Manager's generic-Linux integration — merges
#   Nix data dirs into XDG_DATA_DIRS (so Nix .desktop files reach the system menu)
#   and wires session variables for non-NixOS login managers.
# - nixGL: GPU-library wrappers so Nix-built OpenGL apps (kitty, browsers) use the
#   host's GL drivers instead of Nix's. onyx and quartz are both Intel-primary
#   PRIME laptops, so the default `mesa` wrapper drives the desktop GPU; the Nvidia
#   dGPU is an offload path (would need an nvidia* wrapper + `--impure`). Apps opt
#   in via `config.lib.nixGL.wrap` in desktops/apps.nix (identity where unset).
{
  inputs,
  lib,
  osConfig ? null,
  ...
}:

lib.mkIf (osConfig == null) {
  targets.genericLinux.enable = true;
  targets.genericLinux.nixGL = {
    packages = inputs.nixgl.packages;
    defaultWrapper = "mesa";
  };
}
