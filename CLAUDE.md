# CLAUDE.md

Guidance for Claude Code (and any coding agent) working in this repo.

## What this repo is

A **public, reusable NixOS + Home Manager framework**. It exports `lib.mkHost`,
shared `nixosModules`/`homeModules`, an overlay, and packages. It is consumed by
a **private** flake (`nix-secrets`) that supplies concrete hosts, identity, and
secrets.

## Hard rules

- **No personal data, ever.** No usernames, no real hostnames as config, no age
  recipients, no disk device paths, no location, no encrypted secrets. If a
  change would embed any of these, it belongs in `nix-secrets`, not here.
- **No `nixosConfigurations`.** This repo is a framework; it must not build a
  concrete host. Concrete hosts live in the consumer.
- **Modules stay identity- and asset-agnostic.** Home modules read personal
  files from `assetsDir` (a `specialArg`); per-host values come from
  `hostSettings`. Never hardcode a hostname/username/asset path in a module.
- **Flakes only see git-tracked files.** `git add` new files before
  `nix flake check` / `nixos-rebuild`.

## Layout

- `lib/` — `mk-host.nix` (host factory), `mk-disko.nix` (disk template).
- `modules/system/`, `modules/home/` — shared modules. `modules/vm.nix` = VM variant.
- `overlays/`, `pkgs/`, `session/` — dwm + dwm-session.
- `docs/` — Diátaxis zones (see below).

## Validation

Use Nix directly (no pre-commit wired here yet):

```bash
nix flake check
nix build .#packages.x86_64-linux.dwm-session
nix fmt   # formatter.<system> = nixfmt-rfc-style
```

## Documentation

Docs follow the `docs-design` canon: [Diátaxis](https://diataxis.fr/) zones
(`decisions/`, `guides/`, `reference/`, `explanation/`), lean ADRs ≤350 words
(never deleted — superseded/rejected instead), single-source-of-truth placement,
and drafts kept out of `docs/` under `.draft/` (gitignored). Start at
`docs/README.md`; load `docs/AGENTS.md` for the digest. ADRs: `docs/decisions/`,
numbered `ADR-<NNNN>-<slug>.md`, from `docs/decisions/template.md`.
