# `mkHost` and `mkHomeHost`

`lib.mkHost` builds a NixOS host from this public framework plus a consumer
host module. `lib.mkHomeHost` builds a standalone Home Manager host.

Both factories accept:

- `hostname`
- `username`
- `hostSettings`
- `publicAppsDir`
- `privateAppsDir`
- `extraModules`
- `extraHomeModules`

`publicAppsDir` defaults to this repo's `home/apps`; `privateAppsDir` defaults to
`null`. Both remain accepted, but under per-app atomicity (ADR-0020) they no
longer split a single app across the two repos: an app is atomic and lives wholly
in one repo. A consumer passes its own self-contained, private-bearing apps via
`extraHomeModules` instead.

Each app uses relative assets in its own directory. Public apps (no private part)
ship here; a consumer owns concrete host names, user names, hardware profiles,
recipient scaffolding, and every app that carries a private part.
