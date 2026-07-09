# nix-config — Docs

Documentation for the reusable NixOS + Home Manager framework: what it exports,
how a consumer flake uses it, and the decisions behind the public/private split.

Organized by [Diátaxis](https://diataxis.fr/) reader need (the layout the
`docs-design` canon prescribes). This README is only an index into the zones; it
is not itself a source of rules.

## Zones

| Zone            | Reader need   | Start here                                                                             |
| --------------- | ------------- | -------------------------------------------------------------------------------------- |
| **explanation** | Understanding | [The public/private model](explanation/public-private-model.md)                        |
| **guides**      | Task          | [Bootstrap your nix-secrets](guides/bootstrap-your-nix-secrets.md)                      |
| **reference**   | Lookup        | [mkHost](reference/mk-host.md) · [mkDisko](reference/mk-disko.md)                       |
| **decisions**   | Why           | [ADR index](#decisions) below                                                          |

For coding agents: load [AGENTS.md](AGENTS.md) first for the digest, then read
the zone that owns the change.

## Decisions

Lean ADRs (never deleted; superseded or rejected instead). Template:
[decisions/template.md](decisions/template.md).

- [ADR-0001 — Public framework, private consumer](decisions/ADR-0001-public-private-split.md)
- [ADR-0002 — mkHost parameterization](decisions/ADR-0002-mkhost-parameterization.md)
- [ADR-0003 — Assets live in the consumer](decisions/ADR-0003-assets-live-in-consumer.md)
