# AGENTS

Coding-agent entry point for `nix-config`.

This repo is the public NixOS + Home Manager framework: reusable factories,
shared modules, overlays, packages, and public-safe assets. Concrete private
hosts and identities live in the private consumer repo.

- Authoring rules and hard constraints: [CLAUDE.md](CLAUDE.md).
- Documentation digest: [docs/AGENTS.md](docs/AGENTS.md).
- Documentation index: [docs/README.md](docs/README.md).

Critical rules: never introduce personal-identifying strings (concrete
hostnames, usernames, hardware facts, private repo URLs) into this public repo;
never commit plaintext secrets or private keys; never add a private flake input;
keep shared modules parameterized.

These rules are backed by pre-commit hooks (fast hygiene + secret scanning) and
pre-push hooks (thorough secret-history and link checks), not by any committed
denylist of private strings. See [CLAUDE.md](CLAUDE.md) and
[ADR-0010](docs/decisions/ADR-0010-enforce-public-hygiene-with-hooks.md).
