# ADR-0005: Assets live in the consolidated repo

## Context and Problem Statement

Home Manager modules copy dotfile assets from an injected `assetsDir`. The old
consumer-only asset home no longer fits the consolidated source-of-truth model.

## Considered Options

- Keep assets in a separate private consumer.
- Rewrite assets into Home Manager option DSL.
- Store verbatim assets in this repo under `home/assets/`.

## Decision Outcome

Chosen option: **store verbatim assets in `home/assets/`**. Modules keep the
existing `assetsDir + "/..."` copy contract while flake outputs pass the in-repo
asset path.

## Consequences

- Good: config files stay byte-for-byte portable from Stow where practical.
- Good: both NixOS and standalone Home Manager hosts share one asset tree.
- Bad: asset parity must be reviewed carefully because personal non-secret
  config is now intentionally in the consolidated repo.

## Status

Accepted. Supersedes
[ADR-0003](ADR-0003-assets-live-in-consumer.md).
