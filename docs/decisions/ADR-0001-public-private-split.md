# ADR-0001: Public framework, private consumer

## Context and Problem Statement

The NixOS source-of-truth began as a `nix/` subtree in a personal dotfiles
monorepo, mixing reusable logic (a host factory, shared modules, an overlay)
with personal identity (usernames, hostnames, real disk/GPU identifiers,
encrypted secrets). Publishing it as-is would leak personal data; keeping it
private would waste reusable work. We want the reusable part public without
exposing anything personal.

## Considered Options

- Single sanitized public repo (strip secrets, keep hosts).
- Public framework + private consumer that feeds identity/secrets in.
- Keep everything private.

## Decision Outcome

Chosen option: **public framework + private consumer**. `nix-config` (this repo)
exports `lib.mkHost`, shared `nixosModules`/`homeModules`, an overlay, and
packages — and **no `nixosConfigurations`**. The private `nix-secrets` imports it
as a flake input, supplies concrete hosts/identity/assets/secrets, and calls
`mkHost`. The public repo cannot build a concrete host by itself, so it can
never embed personal data.

## Consequences

- Good: clean separation; the framework is genuinely reusable; personal data has
  exactly one home (the consumer); each repo has independent lock discipline.
- Good: "public feeds from personal info internally" — the dependency points one
  way (consumer → framework), never the reverse.
- Bad: a working host now spans two repos; a change touching both needs two
  commits and a lock bump in the consumer.

## Status

Superseded by
[ADR-0004](ADR-0004-consolidated-nix-config-source-of-truth.md). The
framework/consumer split was reversed when `nix-secrets` was folded into this
repo.
