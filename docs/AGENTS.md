# Docs Digest

Documentation follows Diataxis:

- `decisions/` for ADRs.
- `explanation/` for conceptual background.
- `guides/` for procedures and examples.
- `reference/` for stable API and layout facts.

Public docs must describe reusable framework behavior only. Concrete private
hostnames, usernames, hardware identities, work assets, private repository URLs,
and real recipient material belong in the private consumer repo.

Accepted ADRs are never deleted. Supersede them with a new ADR when direction
changes.

These doc rules, like the repo's hygiene rules, are enforced generically by
pre-commit/pre-push hooks (secret scanning, link checks) rather than by any
committed denylist of private strings — see
[ADR-0010](decisions/ADR-0010-enforce-public-hygiene-with-hooks.md).

Development uses the standard fmt/lint/check/test tiers via `just` and a flake
devShell; the required test tier is `nix flake check`. See
[ADR-0011](decisions/ADR-0011-adopt-standard-dev-tooling.md) and
[guides/development.md](guides/development.md).
