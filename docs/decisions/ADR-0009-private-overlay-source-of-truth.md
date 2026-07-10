# ADR-0009: Private Overlay Source of Truth

Status: Accepted

Supersedes: private-data portions of ADR-0004 and ADR-0005

## Context

ADR-0004 and ADR-0005 consolidated concrete hosts, identities, hardware facts,
assets, and secret scaffolding into public `nix-config`. That made the public
tree too broad: personal and work-specific data can appear in normal framework
changes.

## Decision

`nix-config` is a public framework only. It exports factories, modules,
overlays, packages, and public-safe assets. Concrete hosts, user identities,
private hardware facts, work assets, private recipient scaffolding, and future
ciphertext live in the private consumer.

The dependency direction is fixed: private consumer imports public
`nix-config`. Public `nix-config` never imports the private consumer because a
public `flake.lock` would expose the private input URL, branch, and revision.

Public GitHub namespace references for this repo and the public dwm fork remain
accepted public-identity exceptions. Public openSUSE distribution references in
the generic agent base image remain public technical references, not work data.

## Consequences

Concrete host outputs are removed from this flake. Shared modules accept
`publicAssetsDir`, optional `privateAssetsDir`, and extra module hooks so private
consumers can overlay host-specific behavior without broad directory conflicts.
