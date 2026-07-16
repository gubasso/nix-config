# ADR-0016: Relocate lazy.nvim lockfile out of the read-only config store

## Context and Problem Statement

The nvim config deploys read-only into the Nix store via `mkRealConfigDir`, so
`~/.config/nvim` is immutable and root-owned. lazy.nvim defaults its lockfile to
`stdpath("config")/lazy-lock.json`, so `:Lazy sync` fails with `Permission
denied`. The lockfile is the *only* file lazy writes into the config tree —
plugin clones and checker state already default under `stdpath("data")` and
`stdpath("state")`.

## Considered Options

- A. Relocate the lockfile to the writable state dir via the native `lockfile`
  opt.
- B. Option A plus a Home-Manager activation step seeding the state lockfile from
  a repo-committed lock (keeps pins reproducible / Nix-tracked).
- C. `mkOutOfStoreSymlink` the live repo tree into `~/.config/nvim` (config
  becomes mutable).

## Decision Outcome

Chosen: **Option A**. In `home/apps/nvim/config/init.lua`, set
`lockfile = vim.fn.stdpath("state") .. "/lazy/lazy-lock.json"`. We do not need
fresh-machine plugin-pin restoration for nvim, so the committed lock is not
authoritative. Rejected C — it makes the config mutable, breaking store
ownership and atomic HM management.

## Option B (deferred — enact only if pins must be Nix-tracked)

Keep the `lockfile` relocation and add, in `home/apps/nvim/default.nix`:

```nix
home.activation.seedLazyLock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  install -Dm644 ${./config/lazy-lock.json} \
    "$HOME/.local/state/nvim/lazy/lazy-lock.json"
'';
```

The committed lock then seeds installs (`:Lazy restore` honors pins); `:Lazy
sync` updates the state copy; copy it back to the repo to commit. Each
`home-manager switch` re-seeds, so commit lock updates before rebuilding.

## Consequences

- Good: `:Lazy sync` works; config stays immutable and store-owned; only runtime
  state relocates.
- Bad: under A the committed `lazy-lock.json` is vestigial (never read). It is
  kept intentionally as the seed source should we ever adopt Option B.

## Status

Implemented (Option A) — `home/apps/nvim/config/init.lua`. Option B documented,
deferred.
