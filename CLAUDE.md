# CLAUDE.md

Guidance for Claude Code and other coding agents working in this repo.

## What this repo is

This is the consolidated NixOS + Home Manager source of truth for the `onyx`
and `quartz` gear. It carries concrete hosts, usernames, hardware profiles,
Home Manager assets, overlays, packages, and the sops-encrypted secret
structure.

Plaintext hostnames, usernames, gear names, and hardware identity are accepted
in this repo. Secret values are not.

## Hard rules

- Only sops-encrypted secret material may be committed under `secrets/`.
- Never commit an age private key, plaintext credential, token, private SSH key,
  exported private GPG key, or decrypted secret.
- Flakes only see git-tracked files. New files must be added by a human before
  `nix flake check` can validate them fully.
- Preserve the gear identity mapping: `onyx -> gubasso`, `quartz -> gbasso`.
  Do not cross usernames between gear.
- Keep shared modules reusable through explicit arguments such as `assetsDir`,
  `hostname`, `username`, and `hostSettings`; put host-only behavior in
  `hosts/<host>/`.

## Layout

- `flake.nix` emits NixOS configs for `orion`, `lyra`, `orion-vmtest`,
  `lyra-vmtest`, and standalone Home Manager configs for `gubasso@nova` and
  `gbasso@tumblesuse`.
- `lib/` contains `mk-host.nix`, `mk-home-host.nix`, and `mk-disko.nix`.
- `hosts/` contains concrete hosts and `gear.nix`.
- `home/assets/` contains verbatim Home Manager asset files.
- `modules/system/` and `modules/home/` contain shared modules.
- `secrets/` contains only encrypted sops material and placeholder directories.
- `docs/` contains Diátaxis documentation and ADRs.

## Validation

Use Nix directly:

```bash
nix flake check
nix build .#packages.x86_64-linux.dwm-session
home-manager build --flake .#gubasso@nova
home-manager build --flake .#gbasso@tumblesuse
nix fmt
```

New files must be git-tracked before flakes can see them. Agents in this
workspace must not run git unless the user explicitly permits it.

## Documentation

Docs follow the docs-design canon: Diátaxis zones, lean ADRs at or below 350
words, accepted decisions are never deleted, and drafts stay under `.draft/`.
Start at `docs/README.md`; load `docs/AGENTS.md` for the digest. ADRs live in
`docs/decisions/`, use `ADR-<NNNN>-<slug>.md`, and follow
`docs/decisions/template.md`.
