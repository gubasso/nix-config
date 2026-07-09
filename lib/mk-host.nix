# Host factory (public framework). Wires the shared module set once and threads
# per-host identity + data through specialArgs. A consumer flake (e.g. the
# private nix-secrets) calls this once per host; it never lives here.
#
# The shared system modules and the Home Manager base are injected below from
# THIS repo, so a consumer host only supplies what is genuinely per-machine:
# its hardware profile, disk layout, identity, and assets. Nothing in a consumer
# module needs to reference `inputs.nix-config` — everything shared arrives
# either as an injected module or via specialArgs.
#
# Args (curried): { inputs } (bound by this flake) then a per-host attrset:
#   hostname     - NixOS networking.hostName; also a specialArg for modules.
#   username     - primary user; threaded to system modules and Home Manager.
#   hostModule   - path/module for this host (hosts/<name>/default.nix in the
#                  consumer): hardware import, disko, packages, user, stateVersion.
#   homeModule   - path/module for this host's Home Manager extras
#                  (hosts/<name>/home.nix). The shared home base is injected, so
#                  this only carries host-only home config.
#   assetsDir    - path to the consumer's Home Manager asset tree (dotfiles).
#                  Threaded to home modules, which read files as `assetsDir + "/…"`.
#   hostSettings - per-host data attrset (e.g. { dpi = 192; scale = 2; }) consumed
#                  by modules/home/graphics.nix.
#   system       - platform double (default x86_64-linux).
#   diskDevice   - block device for disko (default the confirmed NVMe); override
#                  to the VM disk for `nixos-anywhere --vm-test`.
#   luksPasswordFile - LUKS password file threaded to the disko layout. Default
#                  null (interactive askPassword on metal); the `*-vmtest`
#                  variants set a store-path test password for shellcheck-clean
#                  `--vm-test`.
#   extraModules - extra NixOS modules for this host.
{ inputs }:
{
  hostname,
  username,
  hostModule,
  homeModule,
  assetsDir,
  hostSettings ? { },
  system ? "x86_64-linux",
  diskDevice ? "/dev/nvme0n1",
  luksPasswordFile ? null,
  extraModules ? [ ],
}:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit
      inputs
      hostname
      username
      diskDevice
      luksPasswordFile
      hostSettings
      ;
    # Shared disko template exposed as a function so a consumer's
    # hosts/<name>/disko.nix stays a thin call with no cross-flake import.
    mkDisko = import ./mk-disko.nix;
  };

  modules = [
    # Per-host module supplied by the consumer.
    hostModule

    # Shared system modules (this repo). A consumer host imports none of these.
    ../modules/system/base.nix
    ../modules/system/boot.nix
    ../modules/system/users.nix
    ../modules/system/secrets.nix
    ../modules/system/power.nix
    ../modules/system/audio.nix
    ../modules/system/network.nix
    ../modules/system/session.nix
    ../modules/vm.nix

    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager

    {
      nixpkgs.overlays = [ (import ../overlays { inherit inputs; }) ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit
          inputs
          hostname
          username
          hostSettings
          assetsDir
          ;
      };
      # Shared Home Manager base (this repo) + the consumer's host-only extras.
      home-manager.users.${username}.imports = [
        ../modules/home/common.nix
        homeModule
      ];
    }
  ]
  ++ extraModules;
}
