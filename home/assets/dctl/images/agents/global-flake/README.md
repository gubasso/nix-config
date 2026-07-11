# dctl global toolset flake

`flake.nix` here defines the global CLI set installed into the persistent `/nix`
volume by `../nix-bootstrap.sh` (`nix profile add /opt/dctl/global-flake#default`).

## Scope: global CLIs only — keep it lean

This profile is deliberately limited to **global user CLIs**: the tools you want on
PATH in _every_ shell regardless of project — agent CLIs, the `direnv`/`nix-direnv`
stack, shell UX (`starship`, `zoxide`, `ripgrep`, `neovim`, …), and VCS CLIs
(`gh`, `glab`).

**Project-particular tooling does NOT belong here** — it lives in each repo's own
flake devShell so it runs with that project's pinned versions. That explicitly
excludes:

- task runners / test frameworks — `just`, `bats`
- language helper CLIs — `cargo-nextest`, `cargo-deny`, `cargo-audit`
- `pre-commit` **and** its `language: system` hook tools — `dprint`, `taplo`,
  `typos`, `shellharden`, `ripsecrets`, `ast-grep`, `gitleaks`

Rule of thumb: if only _some_ projects need it, or it wants a project-pinned version,
it goes in that project's flake — not here. See the repo's `dctl/nix-devcontainers.md`
(the "Boundary" and "Pre-commit is per-project" sections) for the full rationale.

## flake.lock is required and must be generated on a host with Nix

The lock is **not** committed by tooling — generate it once on the host (where
Nix + network exist), then commit it so image builds are reproducible:

```sh
cd ~/.config/dctl/images/agents/global-flake
nix flake lock          # or: nix flake update  (to refresh nixpkgs)
git add flake.lock
```

Refresh deliberately on the weekly image rebuild — a stale lock pins outdated tool
versions; `claude-code`/`codex` ship ~weekly and lag nixpkgs. For a fresher Claude
Code, add `sadjow/claude-code-nix` as an input and take `claude-code` from it.

Without a committed `flake.lock`, `nix profile add` still works but locks at
install time (not reproducible across rebuilds).
