# CLAUDE.md

Guidance for Claude Code and other coding agents working in this repo.

## What this repo is

This is the public NixOS + Home Manager framework. It carries reusable host
factories, shared modules, overlays, packages, and public-safe assets.

Concrete hostnames, usernames, private hardware facts, work assets, real age
recipients, encrypted secret payloads, and plaintext credentials do not belong
here. Private consumers own that data and import this framework.

## Hard rules

- This repository is public. It must never contain personal-identifying
  strings — concrete hostnames, usernames, hardware identifiers, physical
  location, or private repository URLs/revisions. Such data belongs only in the
  private consumer.
- Never commit plaintext secrets, age private keys, private SSH keys, exported
  private GPG keys, tokens, or decrypted secret files.
- Do not add private repositories as flake inputs. Public `flake.lock` must stay
  free of private URLs, branches, and revisions.
- Keep shared modules reusable through explicit arguments such as
  `publicAssetsDir`, `privateAssetsDir`, `hostname`, `username`, and
  `hostSettings`.
- Flakes only see git-tracked files. Humans must track new files before Nix
  validation can fully see them.

## Layout

- `flake.nix` exports factories, modules, overlays, packages, and a formatter.
- `lib/` contains `mk-host.nix`, `mk-home-host.nix`, and `mk-disko.nix`.
- `home/assets/` contains only public-safe generic assets.
- `modules/system/` and `modules/home/` contain shared modules.
- `docs/` contains Diataxis documentation and ADRs.

## Enforcement

Repository hygiene is enforced by pre-commit, not by prose alone. Consolidated
community hooks do the generic work — secret and private-key detection, baseline
hygiene, shell linting — without ever naming a private string. `repo: local`
scripts cover only the cases with no consolidated equivalent: the `secrets/**`
sops-managed guard and the public `flake.lock` host allowlist. No committed hook
encodes a denylist of private strings — that would leak the very identifiers it
guards; keeping the public tree free of personal data stays a rule authors and
agents uphold, backed by the generic secret scanners and review.

Fast, auto-fixing checks run at pre-commit; slow or networked checks (deep
secret-history scan, documentation link check) run at pre-push:

```bash
pre-commit install --hook-type pre-commit --hook-type pre-push
pre-commit run --all-files
```

See [ADR-0010](docs/decisions/ADR-0010-enforce-public-hygiene-with-hooks.md).

## Validation

Human-only validation after edits (pre-commit deliberately never runs Nix
evaluation):

```bash
nix fmt
nix flake check
nix build .#packages.x86_64-linux.dwm-session
```

Agents in this workspace must not run git unless the user explicitly permits it.
