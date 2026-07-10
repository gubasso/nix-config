# `mkHost` and `mkHomeHost`

`lib.mkHost` builds a NixOS host from this public framework plus a consumer
host module. `lib.mkHomeHost` builds a standalone Home Manager host.

Both factories accept:

- `hostname`
- `username`
- `hostSettings`
- `publicAssetsDir`
- `privateAssetsDir`
- compatibility `assetsDir`
- `extraModules`
- `extraHomeModules`

`publicAssetsDir` defaults to this repo's `home/assets`. If
`privateAssetsDir` is provided, compatibility `assetsDir` points there;
otherwise it points at `publicAssetsDir`.

Shared modules use public assets for generic files and optional private assets
for per-host overlays. Private consumers own concrete host names, user names,
hardware profiles, recipient scaffolding, and private assets.
