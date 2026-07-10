# ADR-0008: Legacy Stow Completion

## Context and Problem Statement

`/workspaces/.dotfiles` is being retired as the long-term configuration source of truth. Remaining Stow packages include static non-secret assets, system-scoped files, hook-only behavior, account state, and work-sensitive configuration. The migration must not create secrets, run live activation, or guess host runtime state.

## Considered Options

- Keep the legacy Stow repository as the active source indefinitely.
- Reimplement every hook and service during migration.
- Copy durable non-secret assets into `home/assets/`, wire the smallest owning module, and document live-host or sensitive packages as human-only.

## Decision Outcome

Durable non-secret files are copied verbatim into `home/assets/**` and wired through Home Manager or NixOS modules where ownership is clear. Hook-only behavior, credentials, account state, work-sensitive config, and live validation remain explicit human-only follow-ups in `docs/reference/stow-package-status.md`.

## Consequences

`nix-config` becomes the configuration source of truth for migratable assets while preserving manual checkpoints for host activation and secret handling. Legacy Stow is retained only as a rollback checklist until cutover is proven.

## Status

Accepted.
