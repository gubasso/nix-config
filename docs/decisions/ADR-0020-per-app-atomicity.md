# ADR-0020: Per-app atomicity for the public/private split

## Status

Accepted. Supersedes [ADR-0015](ADR-0015-atomic-artifact-principle.md) (per-file
atomicity). Mirrors `nix-secrets` ADR-0021 on the private side; enforced by
`check-atomic-artifacts` in the private consumer.

## Context

ADR-0015 made each *file* atomic and allowed an app to be **split** across both
repos as a build-time merge (`pkgs.mkRealConfigDir`: a public base tree + a
private overlay of only the private-bearing files). In practice a dozen apps
(`claude-session`, `codex-session`, `nvim`, `kitty`, `rofi`, `gpg`, `git`,
`browser`, `shell-core`, `yazi`, `dctl`, `thunderbird`) each lived partly here and
partly in `nix-secrets`. Reasoning about, testing, and moving an app meant
touching two repos, and the overlay plumbing (`publicAppsDir`,
per-app `mkRealConfigDir` calls) added coupling the split was meant to avoid.

## Decision

**An app is atomic: each `home/apps/<app>` lives wholly in exactly one repo.**

- An app with **any** private part (identity, secrets, private host names,
  location, work-internal data) — even if most of it is generic — lives entirely
  in `nix-secrets`, including its otherwise-generic base.
- The public `nix-config` ships **only** apps with **no** private part.
- An app directory must **never** exist in both `home/apps` trees at once. The
  public-base + private-overlay pattern for apps is no longer permitted.

Framework utilities stay public and reusable: `pkgs.mkRealConfigDir`,
`themeLib`, `fontPackages`, and the `publicAppsDir`/`privateAppsDir` hooks in
`lib/mk-host.nix` / `lib/mk-home-host.nix` remain available — a now-private app
still deploys its own config dir via `mkRealConfigDir` and resolves its theme via
`themeLib`.

## Consequences

- Good: each app is understood, built, and moved in one repo; no cross-repo
  overlay coupling; enforcement is a simple "app in both trees" check, not a
  byte-identical heuristic.
- Good: private data cannot leak into public, because a private-bearing app is
  never partially public.
- Bad: the public framework no longer ships full app bases for apps that happen
  to carry a private part (e.g. `nvim`, `kitty`); a fresh consumer authors those
  apps themselves. Generic, no-private-part apps remain public and reusable.
