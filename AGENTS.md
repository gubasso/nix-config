# AGENTS

Coding-agent entry point for `nix-config`. This repo is a **public, reusable
NixOS + Home Manager framework** — no hosts, no identity, no secrets.

- Authoring rules and hard constraints: [CLAUDE.md](CLAUDE.md).
- Documentation digest (read first, then the owning zone): [docs/AGENTS.md](docs/AGENTS.md).
- Documentation index: [docs/README.md](docs/README.md).

The single most important rule: **personal data goes in the private consumer
(`nix-secrets`), never here.** Modules stay identity- and asset-agnostic
(`assetsDir` + `hostSettings` via `specialArgs`).
