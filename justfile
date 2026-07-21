# nix-config task runner — see docs/guides/development.md and ADR-0011.
# Enter the toolchain first: `nix develop` (or direnv via .envrc).
# This repo is a framework (no hosts) — it has no build/switch recipes.

# List available recipes
default:
    @just --list

# Format all Nix source (RFC style)
fmt:
    nix fmt

# Lint: anti-patterns (statix) + dead code (deadnix), source only
lint:
    statix check .
    deadnix --fail --exclude home/apps/dctl/images/agents/global-flake/flake.nix flake.nix home/apps lib modules overlays derivations catalog

# Test tier: evaluate the flake and build its checks (packages + format gate)
check:
    nix flake check

# Alias for the required test tier
test: check

# Build the dwm session package (artifact — the `nix build` step)
build-dwm:
    nix build .#dwm-session

# Run every pre-commit hook against all files
hooks:
    pre-commit run --all-files

# Install the git hooks (one-time per clone)
hooks-install:
    pre-commit install --hook-type pre-commit --hook-type pre-push
