# Non-NixOS (generic Linux) enablement for standalone Home Manager hosts.
# Self-gates on `osConfig == null` (the standalone-HM signal, same gate as
# env-shell.nix); a no-op on NixOS, where the system already provides all of this.
#
# - targets.genericLinux.enable: Home Manager's generic-Linux integration — merges
#   Nix data dirs into XDG_DATA_DIRS (so Nix .desktop files reach the system menu)
#   and wires session variables for non-NixOS login managers. It ALSO appends an
#   unconditional source of nix.sh + hm-session-vars.sh into ~/.bashrc (upstream
#   home-manager modules/targets/generic-linux.nix:78-81). That ~/.bashrc is
#   bind-mounted into dctl devcontainers, which never run Home Manager, so
#   hm-session-vars.sh is absent there and the source errors at shell start.
#
#   We fix that AT THE SOURCE: disable the upstream module and import a copy
#   patched to guard the hm-session-vars source with `[ -f ] && .`
#   (patches/hm-generic-linux-guard.patch). The guard is a no-op on the host (file
#   present) and silent in containers. We patch rather than: mkForce
#   programs.bash.initExtra (it has 6 contributors — shell-core/starship/direnv/
#   kitty/fzf/generic-linux — mkForce would clobber all of them), or disable
#   genericLinux (its whole `config`, incl. nixGL, is gated on `enable`).
# - nixGL: GPU-library wrappers so Nix-built OpenGL apps (kitty, browsers) use the
#   host's GL drivers instead of Nix's. onyx and quartz are both Intel-primary
#   PRIME laptops, so the default `mesa` wrapper drives the desktop GPU; the Nvidia
#   dGPU is an offload path (would need an nvidia* wrapper + `--impure`). Apps opt
#   in via `config.lib.nixGL.wrap` in co-located app modules (identity where unset).
{
  inputs,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:

let
  isStandalone = osConfig == null;

  # home-manager's `modules/targets` subtree with the one-line guard patch applied.
  # The whole subtree is patched (not just the single file) so generic-linux.nix's
  # relative imports (./generic-linux/nixgl.nix, ./generic-linux/gpu) travel with
  # it. Only forced on standalone hosts (lazy — no IFD on NixOS).
  patchedTargets = pkgs.applyPatches {
    name = "hm-targets-generic-linux-guarded";
    src = "${inputs.home-manager}/modules/targets";
    patches = [ ./patches/hm-generic-linux-guard.patch ];
  };
in
{
  # Swap the upstream module for the guarded copy (modulesPath-relative disable).
  disabledModules = lib.optionals isStandalone [ "targets/generic-linux.nix" ];
  imports = lib.optionals isStandalone [ "${patchedTargets}/generic-linux.nix" ];

  config = lib.mkIf isStandalone {
    targets.genericLinux.enable = true;
    targets.genericLinux.nixGL = {
      packages = inputs.nixgl.packages;
      defaultWrapper = "mesa";
    };
  };
}
