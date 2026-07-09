# nix-config Docs

Documentation for the consolidated NixOS + Home Manager source of truth. This
README is an index into the Diátaxis zones, not a source of rules.

## Zones

| Zone | Reader need | Start here |
| --- | --- | --- |
| **decisions** | Why | [ADR index](#decisions) |
| **guides** | Tasks | [Install guides](guides/install/README.md) |
| **reference** | Lookup | [Hosts](reference/hosts.md) · [mkHost](reference/mk-host.md) · [mkDisko](reference/mk-disko.md) |
| **explanation** | Understanding | [Legacy consumer model](explanation/legacy-consumer-model.md) |

For coding agents: load [AGENTS.md](AGENTS.md) first, then read the owning zone.

## Decisions

Lean ADRs are never deleted; supersede or reject them instead. Template:
[decisions/template.md](decisions/template.md).

- [ADR-0001: Public framework, private consumer](decisions/ADR-0001-public-private-split.md)
- [ADR-0002: mkHost parameterization](decisions/ADR-0002-mkhost-parameterization.md)
- [ADR-0003: Assets live in the consumer](decisions/ADR-0003-assets-live-in-consumer.md)
- [ADR-0004: Consolidated nix-config source of truth](decisions/ADR-0004-consolidated-nix-config-source-of-truth.md)
- [ADR-0005: Assets live in the consolidated repo](decisions/ADR-0005-assets-live-in-consolidated-repo.md)
- [ADR-0006: Standalone Home Manager hosts](decisions/ADR-0006-standalone-home-manager-hosts.md)
- [ADR-0007: sops recipients for NixOS and standalone HM](decisions/ADR-0007-sops-recipients-for-nixos-and-standalone-hm.md)
