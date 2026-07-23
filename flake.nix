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
    # (tumblesuse). Wired via modules/home/generic-linux.nix.
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NOTE: source-only deps of a SINGLE app/component (yazi plugins, the dwm
    # fork, a yazi flavor, ...) are deliberately NOT declared here. They are
    # fetched in place with pkgs.fetchFromGitHub next to their one consumer
    # (home/apps/<app>/, derivations/<pkg>/) so each component's setup stays
    # self-contained instead of scattered into this shared file. Only
    # framework-wide inputs and real flakes consumed for their outputs (e.g.
    # nixgl.packages) belong here.
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import ./overlays) ];
        config.allowUnfree = true;
      };
      mkHost = import ./lib/mk-host.nix { inherit inputs; };
      mkHomeHost = import ./lib/mk-home-host.nix { inherit inputs; };
    in
    {
      lib = {
        inherit mkHost mkHomeHost;
        mkDisko = import ./lib/mk-disko.nix;
        # Theme resolver + emitters over ./themes (also on pkgs as `themeLib`).
        theme = import ./lib/theme { inherit (nixpkgs) lib; };
        # Env-catalog renderer (also on pkgs as `envLib`). See lib/env.nix.
        env = import ./lib/env.nix { inherit (nixpkgs) lib; };
      };

      nixosModules = {
        system-audio = ./modules/system/audio.nix;
        system-base = ./modules/system/base.nix;
        system-boot = ./modules/system/boot.nix;
        system-network = ./modules/system/network.nix;
        system-power = ./modules/system/power.nix;
        system-secrets = ./modules/system/secrets.nix;
        system-session = ./modules/system/session;
        system-users = ./modules/system/users.nix;
        system-xdg-portal = ./modules/system/xdg-portal.nix;
        vm = ./modules/vm.nix;
      };

      homeModules = {
        common = ./modules/home/common.nix;
        apps = ./home/apps;
        env-shell = ./modules/home/env-shell.nix;
        generic-linux = ./modules/home/generic-linux.nix;
        keyring = ./modules/home/keyring.nix;
      };

      overlays.default = import ./overlays;

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
          find ${./flake.nix} ${./lib} ${./modules} ${./overlays} ${./derivations} ${./catalog} ${./themes} \
            -name '*.nix' -print0 | xargs -0 nixfmt --check
          touch "$out"
        '';
      };
    };
}
