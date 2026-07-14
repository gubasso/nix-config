{ inputs }:
{
  hostname,
  username,
  homeModule,
  publicAppsDir ? ../home/apps,
  privateAppsDir ? null,
  hostSettings ? { },
  system ? "x86_64-linux",
  extraModules ? [ ],
  extraHomeModules ? [ ],
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ (import ../overlays { inherit inputs; }) ];
    config.allowUnfree = true;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  extraSpecialArgs = {
    inherit
      inputs
      hostname
      username
      hostSettings
      publicAppsDir
      privateAppsDir
      ;
  };

  modules = [
    ../modules/home/common.nix
    inputs.sops-nix.homeManagerModules.sops
    {
      sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    }
    homeModule
  ]
  ++ extraHomeModules
  ++ extraModules;
}
