{
  description = "Reusable NixOS + Home Manager framework: host factory, shared modules, overlays, and packages. A private consumer flake (nix-secrets) supplies hosts, identity, and secrets.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Personal dwm fork (SoT: github.com/gubasso/dwm, branch rice). Not a flake;
    # consumed only as a source tree by pkgs/dwm. Bump with:
    #   nix flake update dwm-fork
    dwm-fork = {
      url = "github:gubasso/dwm/rice";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import ./overlays { inherit inputs; }) ];
        config.allowUnfree = true;
      };
    in
    {
      # Host factory. A consumer calls `lib.mkHost { hostname; username;
      # hostModule; homeModule; assetsDir; hostSettings; }` per host. See
      # lib/mk-host.nix for the full argument contract.
      lib = {
        mkHost = import ./lib/mk-host.nix { inherit inputs; };
        mkDisko = import ./lib/mk-disko.nix;
      };

      # Shared system modules. mkHost injects the standard set automatically;
      # these are also exported for consumers that compose their own host.
      nixosModules = {
        system-audio = ./modules/system/audio.nix;
        system-base = ./modules/system/base.nix;
        system-boot = ./modules/system/boot.nix;
        system-network = ./modules/system/network.nix;
        system-power = ./modules/system/power.nix;
        system-secrets = ./modules/system/secrets.nix;
        system-session = ./modules/system/session.nix;
        system-users = ./modules/system/users.nix;
        vm = ./modules/vm.nix;
      };

      # Home Manager modules. mkHost injects `common` (which imports the rest);
      # exported here for direct composition.
      homeModules = {
        common = ./modules/home/common.nix;
        core-cli = ./modules/home/core-cli.nix;
        desktop = ./modules/home/desktop.nix;
        env-shell = ./modules/home/env-shell.nix;
        graphics = ./modules/home/graphics.nix;
        keyring = ./modules/home/keyring.nix;
      };

      overlays.default = import ./overlays { inherit inputs; };

      packages.${system} = {
        dwm = pkgs.dwm;
        dwm-session = pkgs.dwm-session;
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
