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

`publicAppsDir` defaults to this repo's `home/apps`. `privateAppsDir`, when
provided by a consumer, points at the consumer's private co-located app tree.

Shared app modules use relative assets in their own app directories. Private
consumers own concrete host names, user names, hardware profiles, recipient
scaffolding, and private app overlays.
