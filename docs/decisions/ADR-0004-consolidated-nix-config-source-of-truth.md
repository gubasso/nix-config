# ADR-0004: Consolidated nix-config source of truth

## Context and Problem Statement

The former model split reusable framework code in `nix-config` from private
hosts, identity, assets, and secrets scaffold in `nix-secrets`. Operating real
hosts required two repos and a flake-input lock step.

## Considered Options

- Keep the public framework plus private consumer split.
- Consolidate host reality into `nix-config`.
- Start a new greenfield repo.

## Decision Outcome

Chosen option: **consolidate host reality into `nix-config`**. This repo now
emits concrete NixOS and Home Manager configurations and is the single source of
truth for hosts, modules, assets, hardware profiles, and sops-encrypted secrets.

## Consequences

- Good: one repo builds every host and keeps host wiring DRY.
- Good: the old consumer lock-step disappears.
- Bad: the repo intentionally contains accepted plaintext identity and
  hardware facts, plus encrypted secret files.

## Status

Accepted. Supersedes
[ADR-0001](ADR-0001-public-private-split.md) and the external `nix-secrets`
decision `ADR-0001-consume-nix-config-as-flake-input.md`. Its private-data
consolidation stance is partially superseded by
[ADR-0009](ADR-0009-private-overlay-source-of-truth.md), which moves concrete
hosts, identities, private assets, and secrets scaffolding back into private
`nix-secrets`.
