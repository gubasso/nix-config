---
digest-of: nix-config/docs
last-synced: 2026-07-09
source-files:
  - README.md
  - reference/hosts.md
  - reference/mk-host.md
  - reference/mk-disko.md
  - decisions/ADR-0001-public-private-split.md
  - decisions/ADR-0002-mkhost-parameterization.md
  - decisions/ADR-0003-assets-live-in-consumer.md
  - decisions/ADR-0004-consolidated-nix-config-source-of-truth.md
  - decisions/ADR-0005-assets-live-in-consolidated-repo.md
  - decisions/ADR-0006-standalone-home-manager-hosts.md
  - decisions/ADR-0007-sops-recipients-for-nixos-and-standalone-hm.md
---

# AGENTS

## Scope

Documentation for the consolidated `nix-config` repo. Load this digest first,
then read the zone file that owns the change. Zone files are authoritative.

## Key Rules

- Plaintext hostnames, usernames, gear names, and hardware identity are accepted.
- Secret values must be sops-encrypted at rest; age private keys are never
  committed.
- Gear identity is fixed: `onyx -> gubasso`, `quartz -> gbasso`.
- New files must be git-tracked by a human before flake validation can see them.

## Key Points

- `flake.nix` emits NixOS configs for `orion`, `lyra`, `orion-vmtest`, and
  `lyra-vmtest`.
- `flake.nix` emits standalone Home Manager configs for `gubasso@nova` and
  `gbasso@tumblesuse`.
- `mkHost` remains the NixOS factory; `mkHomeHost` is the standalone Home
  Manager sibling.
- Verbatim Home Manager assets live in `home/assets/`.
- `.sops.yaml` defines host scopes for `orion`, `lyra`, `nova`, `tumblesuse`,
  plus sparse `shared`.

## Source Map

| Topic | File |
| --- | --- |
| Host inventory | `reference/hosts.md` |
| NixOS factory | `reference/mk-host.md` |
| Disk layout helper | `reference/mk-disko.md` |
| Recorded decisions | `decisions/ADR-000*.md` |

## Maintenance Notes

Regenerate when the source files above change. When this digest and a zone file
disagree, the zone file wins.
