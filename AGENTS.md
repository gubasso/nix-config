# AGENTS

Coding-agent entry point for `nix-config`.

This repo is the consolidated NixOS + Home Manager source of truth for concrete
hosts, identity, hardware profiles, Home Manager assets, overlays, packages, and
sops-encrypted secret structure.

- Authoring rules and hard constraints: [CLAUDE.md](CLAUDE.md).
- Documentation digest: [docs/AGENTS.md](docs/AGENTS.md).
- Documentation index: [docs/README.md](docs/README.md).

Critical rules: never commit plaintext secrets or age private keys; preserve
`onyx -> gubasso` and `quartz -> gbasso`; remember flakes only see files after a
human has git-tracked them.
