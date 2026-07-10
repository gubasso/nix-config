# ADR-0010: Enforce Public-Repo Hygiene with Pre-Commit and Pre-Push Hooks

## Context and Problem Statement

ADR-0009 made `nix-config` a public framework whose worst failure is leaking
personal or private data (identities, hardware facts, secrets, a private input
URL). Until now that discipline lived only in prose (`CLAUDE.md`, `AGENTS.md`),
and a manual "scan before push" step is easy to skip.

## Considered Options

- Prose rules only (status quo).
- A committed denylist scanner that greps for the real private strings.
- Consolidated pre-commit/pre-push hooks plus minimal custom guards.

## Decision Outcome

Chosen option: **consolidated hooks plus minimal custom guards** — generic
scanners catch secrets and keys without ever naming a private string, and two
`repo: local` guards cover the gaps no community hook fills.

A committed denylist was rejected: it would embed the exact hostnames and
usernames it guards into a public repo, leaking them. Enforcement is generic —
`detect-private-key`, `ripsecrets` (pre-commit), and `gitleaks` (pre-push) find
secrets by shape; the `secrets/**` sops guard and the `flake.lock` public-host
allowlist are the only custom scripts, and both encode allow-rules, not private
data. Fast, auto-fixing checks run at pre-commit; slow or networked checks (deep
history scan, link check) run at pre-push. No CI is added; hooks run locally via
`pre-commit install`.

## Consequences

- Good: the highest-risk leak (a private flake input) is mechanically blocked,
  and secret/key leaks are caught by shape on every commit and push.
- Good: the guards themselves contain no private data, so they are safe to ship
  in a public repo.
- Bad: personal *identifier* strings (a bare hostname) are not machine-detected;
  that residual risk stays covered by the written rules and review, by design.

## Status

Accepted. Enacted by `.pre-commit-config.yaml`,
`scripts/check-no-plaintext-secrets.sh`, and `scripts/check-flake-lock-public.sh`.
