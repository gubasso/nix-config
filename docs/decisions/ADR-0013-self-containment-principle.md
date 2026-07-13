# ADR-0013: Self-containment principle

## Context and Problem Statement

Contributors and agents must be able to understand and operate this repo from
the repo alone. When load-bearing knowledge lives only in external documents,
chats, or private tooling, those references drift, disappear, or fall out of
sync — and the framework stops being self-explaining. This repo already leans
this way (each ADR, module, and asset is meant to explain itself, and
[ADR-0004](ADR-0004-consolidated-nix-config-source-of-truth.md) made
`nix-config` a consolidated source of truth), but the principle was never
stated explicitly.

## Considered Options

- Reference external docs freely as the source of truth.
- Keep all load-bearing knowledge in-repo; treat external links as optional
  further reading.
- Mix both with no rule.

## Decision Outcome

Chosen option: **keep all load-bearing knowledge in-repo** — every artifact
(ADR, module, package, asset) is self-explaining, and consumers need no external
context to use it. An external reference is allowed only as a public link or
citation, never as a load-bearing dependency on a resource outside the repo, and
never on a private, local, personalized, or mutating repository, path, or tool.
When external knowledge is required, its essential substance is copied in. This
complements the public/private split
([ADR-0001](ADR-0001-public-private-split.md),
[ADR-0009](ADR-0009-private-overlay-source-of-truth.md)): private consumers own
their data and import this framework, and the framework stays complete on its
own without reaching into any consumer.

## Consequences

- Good: the repo is self-explanatory and resilient to external link rot; agents
  and contributors work from one source of truth.
- Bad: some duplication of external material, and a discipline cost to keep
  copied knowledge current.

## Status

Accepted.
