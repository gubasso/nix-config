# ADR-0002: mkHost parameterization

## Context and Problem Statement

In the monorepo, `mk-host.nix` imported `../hosts/${hostname}` and
`../modules/...` by relative path. Once hosts move to a separate private repo,
those relative imports break: the factory (public) and the hosts (private) no
longer share a tree. We need the factory to accept per-host inputs without any
cross-repo relative import, and without a consumer module having to reference
`inputs.nix-config` for shared pieces.

## Considered Options

- Consumer imports shared modules via `inputs.nix-config.nixosModules.*` in each
  host module.
- `mkHost` takes the per-host pieces as parameters and injects the shared set
  itself.
- Absolute store-path imports (`"${inputs.nix-config}/modules/..."`).

## Decision Outcome

Chosen option: **`mkHost` takes parameters and injects the shared set**. Its
signature gains `hostModule`, `homeModule`, `assetsDir`, and `hostSettings`. It
injects every shared system module and the Home Manager base from *this* repo,
and threads `mkDisko`, `hostSettings`, and `assetsDir` through
`specialArgs`/`extraSpecialArgs`. A consumer host module therefore imports **none**
of the shared modules and never mentions `inputs.nix-config`.

## Consequences

- Good: consumer host modules shrink to genuinely per-machine content (hardware,
  disko call, user, stateVersion); no cross-repo import boilerplate.
- Good: one wiring point; adding a shared module is a one-line change in `mkHost`.
- Bad: the shared module *set* is fixed by `mkHost`; a host that wants to drop a
  standard module must use `extraModules`/`lib.mkForce` rather than omit an import.

## Status

Implemented in `lib/mk-host.nix`. See [reference/mk-host.md](../reference/mk-host.md)
for the argument contract.
