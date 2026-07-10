# ADR-0011: Adopt Standard Dev Tooling — Formatter, Linters, and a Test Tier

## Context and Problem Statement

ADR-0010 enforced hygiene but kept Nix evaluation and formatting "human-only":
the hooks ran no `nix fmt` or `nix flake check`. That left formatting drift and
evaluation errors to slip in between manual runs. We now treat this repo like a
normal software project with fmt/lint/check/test tiers.

## Considered Options

- Keep Nix evaluation/formatting human-only (ADR-0010 status quo).
- Add a CI system to run the checks.
- Local hooks plus a `just` runner that map the standard tiers onto Nix tools.

## Decision Outcome

Chosen option: **local hooks plus a `just` runner** — mirror the
cargo `fmt`/`clippy`/`check`/`test` model with Nix tools, no CI. `nixfmt`
(format) and `statix` + `deadnix` (lint) are parse-only and run at pre-commit;
`nix flake check` is the test tier — it evaluates the outputs and builds the
package and formatting checks — and runs at pre-push. Full builds (`nix build`,
`nixos-rebuild`) stay human `just` recipes, never hooks: the `cargo build`
analog. Tools ship in the flake `devShell`; the `justfile` persists every
command.

This revises only ADR-0010's "human-only evaluation" clause; its
hygiene and anti-denylist decisions remain in force.

## Consequences

- Good: formatting and evaluation errors are caught mechanically and
  consistently, not by memory.
- Good: one documented command surface (`just`) shared by humans and agents.
- Bad: committing and pushing now require the devShell on PATH, and pre-push is
  slower because it runs `nix flake check`.

## Status

Accepted. Enacted by `flake.nix` (devShells, checks), `.pre-commit-config.yaml`,
`statix.toml`, `justfile`, and
[docs/guides/development.md](../guides/development.md).
