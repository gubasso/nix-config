# ADR-0006: Standalone Home Manager hosts

## Context and Problem Statement

`nova` and `tumblesuse` remain Arch/openSUSE hosts, but their user configuration
should come from the same source of truth as the future NixOS hosts. The NixOS
factory returns `nixosSystem`, which is not the standalone Home Manager contract.

## Considered Options

- Add a `kind` switch to `mkHost`.
- Create a sibling `mkHomeHost` factory.
- Keep non-NixOS hosts on Stow only.

## Decision Outcome

Chosen option: **create `mkHomeHost`**. It returns
`home-manager.lib.homeManagerConfiguration`, injects shared home modules, uses
the same `assetsDir` and gear metadata, and includes the Home Manager sops
module with a user age key.

## Consequences

- Good: NixOS and standalone Home Manager contracts stay clear.
- Good: `gubasso@nova` and `gbasso@tumblesuse` can build before NixOS cutover.
- Bad: drivers, kernels, display managers, and distro services remain native
  until a full NixOS migration.

## Status

Accepted. Extends
[ADR-0002](ADR-0002-mkhost-parameterization.md).
