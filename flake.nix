{
  description = "Public NixOS + Home Manager framework, modules, overlays, packages, and public-safe assets.";

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

    # GPU-library wrappers for running Nix-built OpenGL apps on non-NixOS hosts
    # (nova/tumblesuse). Wired via modules/home/generic-linux.nix.
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Public GitHub fork exception: github.com/gubasso/dwm is an intentional
    # public namespace reference, not private host or work data.
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
      mkHost = import ./lib/mk-host.nix { inherit inputs; };
      mkHomeHost = import ./lib/mk-home-host.nix { inherit inputs; };
    in
    {
      lib = {
        inherit mkHost mkHomeHost;
        mkDisko = import ./lib/mk-disko.nix;
      };

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

      homeModules = {
        common = ./modules/home/common.nix;
        agents = ./modules/home/agents.nix;
        core-cli = ./modules/home/core-cli.nix;
        desktop-apps = ./modules/home/desktops/apps.nix;
        desktop-dwm = ./modules/home/desktops/dwm.nix;
        desktop-kde = ./modules/home/desktops/kde.nix;
        env-shell = ./modules/home/env-shell.nix;
        generic-linux = ./modules/home/generic-linux.nix;
        graphics = ./modules/home/desktops/graphics.nix;
        keyring = ./modules/home/keyring.nix;
      };

      overlays.default = import ./overlays { inherit inputs; };

      packages.${system} = {
        inherit (pkgs) dwm dwm-session;
      };

      # `nix fmt` runs this with no file args; nixfmt-tree (nixfmt wrapped in
      # treefmt) walks the tree and formats every .nix file. A bare `nixfmt`
      # here would read stdin and hang. See `nix fmt --help`.
      formatter.${system} = pkgs.nixfmt-tree;

      # Development toolchain (see docs/guides/development.md). `nix develop`,
      # or direnv via .envrc, puts these on PATH so the pre-commit hooks and the
      # justfile recipes resolve their tools.
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt
          statix
          deadnix
          typos
          just
          pre-commit
          jq
          ripgrep
          gitleaks
          lychee
        ];
      };

      # Test tier: `nix flake check` builds these. The framework's "unit tests"
      # are its package builds plus a repo-wide formatting gate.
      checks.${system} = {
        inherit (pkgs) dwm dwm-session;
        formatting = pkgs.runCommand "nixfmt-check" { nativeBuildInputs = [ pkgs.nixfmt ]; } ''
          find ${./flake.nix} ${./lib} ${./modules} ${./overlays} ${./pkgs} \
            -name '*.nix' -print0 | xargs -0 nixfmt --check
          touch "$out"
        '';
      };
    };
}
