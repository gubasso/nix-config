{
  # dctl global CLI toolset — every *global* user CLI (agent CLIs + shell UX +
  # linters), installed into the persistent /nix volume by nix-bootstrap.sh:
  #   nix profile add /opt/dctl/global-flake#default
  #
  # Per-project *language toolchains* (node/python/rust/zig) AND per-project git
  # hooks (`pre-commit` + its hook tools) come from each project's own flake
  # devShell, not from here — this profile stays global user CLIs only.
  #
  # Reproducibility: flake.lock is committed and pins nixpkgs. Refresh it
  # deliberately on the weekly image rebuild (`nix flake update`), not implicitly.
  description = "dctl global CLI toolset";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # claude-code is unfree; set here so `nix profile add` needs no
          # NIXPKGS_ALLOW_UNFREE / --impure at install time.
          config.allowUnfree = true;
        };
      in
      {
        packages.default = pkgs.buildEnv {
          name = "dctl-global";
          paths = with pkgs; [
            # --- direnv stack (nix-direnv provides `use flake`) ---
            direnv
            nix-direnv

            # --- shell UX (moved off zypper) ---
            starship
            zoxide
            eza
            bat
            fzf
            ripgrep
            fd
            jq
            yq-go # mikefarah yq (the bare `yq` attr is the Python one)
            tree
            htop
            neovim

            # --- general dev CLIs (VCS + safe rm) ---
            gh
            glab
            trash-cli

            # NOTE: project-particular tooling is deliberately NOT here — it lives
            # in each repo's own flake devShell so it runs with the project's
            # pinned toolchain. This profile stays global user CLIs only. That
            # includes:
            #   - task runners / test frameworks: just, bats
            #   - language helper CLIs: cargo-nextest, cargo-deny, cargo-audit
            #   - pre-commit + its `language: system` hook tools: dprint, taplo,
            #     typos, shellharden, ripsecrets, ast-grep, gitleaks

            # --- AI agent CLIs (moved off curl/bun/npm) ---
            claude-code
            codex
            opencode
            gemini-cli
          ];
        };
      }
    );
}
