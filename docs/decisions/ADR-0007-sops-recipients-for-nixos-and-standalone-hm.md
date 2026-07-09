# ADR-0007: sops recipients for NixOS and standalone HM

## Context and Problem Statement

The old private consumer had placeholder host recipients for NixOS only.
Consolidation adds standalone Home Manager hosts, whose activation runs as the
user and cannot rely on `/var/lib/sops-nix/key.txt`.

## Considered Options

- Use one shared recipient for every host.
- Use NixOS host keys only.
- Use per-scope recipients by host type.

## Decision Outcome

Chosen option: **use per-scope recipients by host type**. NixOS hosts use
`/var/lib/sops-nix/key.txt`; standalone Home Manager hosts use
`~/.config/sops/age/keys.txt`. `secrets/shared/` exists only for genuinely
cross-host material.

## Consequences

- Good: each host decrypts only its intended scope plus explicit shared files.
- Good: standalone Home Manager does not inherit root-key assumptions.
- Bad: real recipient collection and rekeying are required before any real
  secret file can be committed.

## Status

Accepted. Re-homes and extends the external `nix-secrets`
`ADR-0002-sops-nix-age-per-host-recipients.md`.
