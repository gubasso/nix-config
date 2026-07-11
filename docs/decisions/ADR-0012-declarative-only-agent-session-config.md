# ADR-0012: Declarative-only agent session config

## Context and Problem Statement

The legacy `~/.dotfiles` Stow repo carried several AI coding-agent packages
(`claude`, `claude-session`, `codex-session`, `gemini`, `opencode`). Some hold
portable, declarative config; others are live/mutable state (credentials, auth
caches, lock files, session directories). Completing the Stow retirement (ADR-0008)
requires deciding what the framework materialises.

## Considered Options

- Migrate every agent package wholesale (config + live state).
- Migrate only the portable declarative config; leave live state user-managed.
- Migrate nothing; keep all agent config in a separate Stow repo.

## Decision Outcome

Chosen option: **migrate only declarative config** — the `modules/home/agents.nix`
module ships the portable `claude-session` and `codex-session` layers
(`settings/base.json`, profiles, config recipes, tier profiles). Live/mutable
state (`~/.claude`, `~/.codex`, `credentials.json`, auth caches, `*.lock`, session
dirs) is **never** materialised by Nix; it stays user-owned and is the same on
every host. The `claude`, `gemini`, and `opencode` packages are **not** migrated —
they are user-managed live state with no declarative payload worth owning. Work
layers (`suse.json`, the codex trusted-projects list) live in the private consumer.

## Consequences

- Good: the framework contains only reproducible config; deleting the legacy repo
  loses nothing, because everything Nix drops is regenerable and live state was
  never in Nix to begin with.
- Good: the dctl `claude`/`codex` devcontainer layers still 1:1-bind the live
  state paths; they resolve because the wrapper config is materialised and the
  user owns the credential state.
- Bad: adding a new agent tool requires a small module edit rather than dropping a
  Stow package.

## Status

Implemented — `modules/home/agents.nix`, registered in `flake.nix` `homeModules`
and `modules/home/common.nix`. Private layers in `nix-secrets`.
