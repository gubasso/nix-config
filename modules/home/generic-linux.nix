# Non-NixOS (generic Linux) enablement for standalone Home Manager hosts.
# The genericLinux integration itself is gated on `osConfig == null` (the
# standalone-HM signal); a no-op on NixOS, where the system already provides it.
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
#
#   Two module-system constraints shape HOW this is wired:
#   1. The disable+import is UNCONDITIONAL (not gated on `osConfig`). `imports` and
#      `disabledModules` are evaluated before `_module.args`, so referencing any
#      config-derived arg there — `osConfig` OR the module `pkgs` — infinite-recurses.
#      The patched copy is inert unless `targets.genericLinux.enable` is set (only
#      for standalone HM, below), so swapping it in on NixOS too is a harmless no-op.
#   2. `applyPatches` needs a nixpkgs, but the module `pkgs` arg is off-limits here
#      (see #1). We build one from `inputs.nixpkgs` — `inputs` is a specialArg, so
#      it is safe in `imports`.
# - nixGL: GPU-library wrappers so Nix-built OpenGL apps (kitty, browsers) use the
#   host's GL drivers instead of Nix's. onyx and quartz are both Intel-primary
#   PRIME laptops, so the default `mesa` wrapper drives the desktop GPU; the Nvidia
#   dGPU is an offload path (would need an nvidia* wrapper + `--impure`). Apps opt
#   in via `config.lib.nixGL.wrap` in co-located app modules (identity where unset).
{
  inputs,
  lib,
  osConfig ? null,
  ...
}:

let
  # nixpkgs from the flake INPUT (a specialArg) — safe to use in `imports`, unlike
  # the module `pkgs` arg. All hosts are x86_64-linux; update if that changes.
  patchPkgs = import inputs.nixpkgs { system = "x86_64-linux"; };

  # home-manager's `modules/targets` subtree with the one-line guard patch applied.
  # The whole subtree is patched (not just the single file) so generic-linux.nix's
  # relative imports (./generic-linux/nixgl.nix, ./generic-linux/gpu) travel with it.
  patchedTargets = patchPkgs.applyPatches {
    name = "hm-targets-generic-linux-guarded";
    src = "${inputs.home-manager}/modules/targets";
    patches = [ ./patches/hm-generic-linux-guard.patch ];
  };
in
{
  # Swap upstream generic-linux for the guarded copy — unconditional (see header).
  # modulesPath-relative disable string matches the upstream key.
  disabledModules = [ "targets/generic-linux.nix" ];
  imports = [ "${patchedTargets}/generic-linux.nix" ];

  # Standalone-HM only (osConfig == null). On NixOS the swap above stays inert.
  config = lib.mkIf (osConfig == null) {
    targets.genericLinux.enable = true;
    targets.genericLinux.nixGL = {
      packages = inputs.nixgl.packages;
      defaultWrapper = "mesa";
    };
  };
}
