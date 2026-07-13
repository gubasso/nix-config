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

Development follows the standard fmt/lint/check/test tiers via a `just` runner
and a flake devShell; the required test tier is `nix flake check` (`just test`).
See [ADR-0011](docs/decisions/ADR-0011-adopt-standard-dev-tooling.md) and
[docs/guides/development.md](docs/guides/development.md).

<!-- self-containment -->
## Self-Containment

Non-negotiable: this framework is self-contained. The knowledge it depends on is
held in-repo. An external reference is allowed only as a public link or citation
for further reading — never as a load-bearing dependency on a resource outside
the repository, and in particular never on a private, local, personalized, or
mutating repository, path, or tool. If external knowledge is required to
understand, build, or operate this repo, copy its essential substance in (a doc,
an ADR, or an inline comment) so the repo stays complete on its own. This is the
public half of the public/private split: private consumers own their data and
import this framework, and the framework never reaches into a consumer. See
[ADR-0013](docs/decisions/ADR-0013-self-containment-principle.md).
