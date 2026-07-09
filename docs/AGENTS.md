---
digest-of: nix-config/docs
last-synced: 2026-07-09
source-files:
  - README.md
  - explanation/public-private-model.md
  - guides/bootstrap-your-nix-secrets.md
  - reference/mk-host.md
  - reference/mk-disko.md
  - decisions/ADR-0001-public-private-split.md
  - decisions/ADR-0002-mkhost-parameterization.md
  - decisions/ADR-0003-assets-live-in-consumer.md
---

# AGENTS

## Scope

How the `nix-config` framework is structured and consumed. Load this digest
first, then read the zone file that owns the change. Zone files are
authoritative; this digest never introduces new rules.

## The one rule

**No personal data in this repo.** Usernames, real hostnames-as-config, age
recipients, disk paths, location, and secrets all live in the private consumer
(`nix-secrets`). Modules stay identity- and asset-agnostic.

## Key points

### Explanation — the model

- Two repos: public `nix-config` (framework) + private `nix-secrets` (hosts,
  identity, secrets). Public has **no `nixosConfigurations`**.
- The consumer imports `nix-config` as a flake input and calls `lib.mkHost` once
  per host. `mkHost` injects the shared module set; the consumer imports none of
  it by hand.

### Reference — the API

- `lib.mkHost { hostname, username, hostModule, homeModule, assetsDir,
  hostSettings ? {}, system ? "x86_64-linux", diskDevice ? "/dev/nvme0n1",
  luksPasswordFile ? null, extraModules ? [] }` → a `nixosSystem`.
- `specialArgs` threaded to system modules: `inputs, hostname, username,
  diskDevice, luksPasswordFile, hostSettings, mkDisko`.
- `extraSpecialArgs` threaded to home modules: `inputs, hostname, username,
  hostSettings, assetsDir`.
- `lib.mkDisko { device, vgName, diskName, swapSize ? "32G", luksPasswordFile ?
  null }` → LUKS-on-LVM disko layout.

### Guides — consuming

- A consumer host = `mkHost` call + `hosts/<name>/{default,disko,home,packages}.nix`
  + a `modules/hardware/<profile>.nix` + `home/assets/` + `hostSettings`.
- `hosts/<name>/disko.nix` calls `mkDisko` (from `specialArgs`), not a relative import.

### Decisions

- ADR-0001 public framework / private consumer · ADR-0002 mkHost parameterization
  (`hostModule`/`homeModule`/`assetsDir`/`hostSettings`) · ADR-0003 assets live in
  the consumer. All Implemented; lean; never deleted.

## Source map

| Topic                              | File                                          |
| ---------------------------------- | --------------------------------------------- |
| Public/private split, why          | `explanation/public-private-model.md`         |
| Consumer walkthrough               | `guides/bootstrap-your-nix-secrets.md`        |
| `mkHost` argument contract         | `reference/mk-host.md`                         |
| `mkDisko` argument contract        | `reference/mk-disko.md`                        |
| Recorded decisions                 | `decisions/ADR-000*.md`                        |

## Maintenance notes

- Regenerate when any `source-files` entry changes; introduce no new rules here.
- When digest and a zone file disagree, the zone file wins; regenerate the digest.
