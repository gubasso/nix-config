# ADR-0015: Atomic Artifact Principle for the public/private split

## Status

Accepted. Enacted by the co-located apps (ADR-0014) and `pkgs.mkRealConfigDir`
(`overlays/default.nix`); enforced by the `check-atomic-artifacts` hook in the
private consumer (`nix-secrets` ADR-0013).

## Context

Cross-repo overlay apps (ADR-0014) let a private consumer override a public app.
The easy but wrong way is to copy the whole public config into the private repo
and let a private `lib.mkForce` win. The public copy is then dead weight — never
deployed, yet duplicated — and the two copies drift. `nvim` had ~99 files
duplicated this way, and a `gammastep` config carrying real coordinates lived in
both repos, leaking location out of the private side.

## Decision

**A config artifact is atomic: each file lives in exactly one repo.** A file
goes in the public `nix-config` only if **nothing inside it is private**
(identity, secrets, private host names, location, work-internal data). If any
part is private, the whole file lives in the private `nix-secrets`.

Never keep the same file in both repos with a private `mkForce` winning. A
genuine public-base + private-overlay is allowed **only** as a build-time merge
where no single file is duplicated:

- `pkgs.mkRealConfigDir name pubDir privDir` — public base tree + private overlay
  of only the private-bearing files (e.g. `nvim`: public owns every generic
  file; private overlays only `host.lua`, host-keyed `colorschemes.lua`, and the
  personal spell file).
- a per-host file whose content genuinely differs (`rofi/hosts/<host>/`),
- `lib.mkAfter` appends (`kitty`),
- public sourcing a private file it does not own (`shell-core`).

Do not over-split; favour maintainability — one clean copy beats a clever split.

## Consequences

- Good: no dead-weight duplication, no drift, and private data (host names,
  location) cannot leak into public by being copied there.
- Good: overlays state their private surface explicitly and minimally.
- Bad: contributors must judge whether a file is private before placing it; the
  enforcement hook only catches byte-identical duplicates, so near-duplicates
  still need human review.
