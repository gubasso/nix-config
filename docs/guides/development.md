# Development and Testing

How to work on `nix-config` as a normal project: a formatter, linters, and a
required test tier, all driven by `just` and enforced by git hooks. The rationale
is [ADR-0011](../decisions/ADR-0011-adopt-standard-dev-tooling.md).

## Toolchain

The tools (`nixfmt`, `statix`, `deadnix`, `typos`, `just`, `pre-commit`, …) ship
in the flake `devShell`. Enter it before working:

```bash
nix develop        # or: direnv allow   (uses .envrc -> `use flake`)
```

Install the git hooks once per clone:

```bash
just hooks-install   # pre-commit install --hook-type pre-commit --hook-type pre-push
```

## The tiers

The workflow mirrors a Rust project's `cargo` tiers:

| Command | Tool(s) | Stage | Analog |
| --- | --- | --- | --- |
| `just fmt` | `nixfmt` | pre-commit (auto-fix) | `cargo fmt` |
| `just lint` | `statix`, `deadnix` | pre-commit (blocking) | `cargo clippy` |
| `just check` / `just test` | `nix flake check` | pre-push | `cargo check` + `cargo test` |
| `just build-dwm` | `nix build` | human only | `cargo build` |

`nix flake check` is the **required test tier**: it evaluates the flake outputs
and builds the `checks` (the `dwm`/`dwm-session` packages and a repo-wide
formatting gate). Every change must pass it before merging. Full builds are a
deliberate human step, never a hook.

The nix lint/format tools are parse-only (they never evaluate the flake). They
are scoped to real source; generated trees are
excluded (via `statix.toml` and the hook `exclude` patterns).

## Running the hooks manually

```bash
just hooks                                     # all pre-commit hooks, all files
pre-commit run --all-files --hook-stage pre-push   # gitleaks, lychee, nix flake check
```
