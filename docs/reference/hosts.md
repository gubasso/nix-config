# Hosts

This public repo intentionally contains no concrete host inventory.

Private consumers define their own:

- host modules under `hosts/<host>/`
- standalone Home Manager modules under `hosts/<host>/home.nix`
- private hardware profiles under their own module tree
- `nixosConfigurations.<host>` and `homeConfigurations."<user>@<host>"`

Use `lib.mkHost` and `lib.mkHomeHost` from this framework. Public apps are
imported from this repo's `home/apps`; a consumer's private-bearing apps are
self-contained under the consumer's own `home/apps/<app>/` and passed via
`extraHomeModules` (per-app atomicity, ADR-0020). `publicAppsDir`/`privateAppsDir`
remain accepted (defaulting to this repo's `home/apps` and `null`) but no longer
split a single app across both repos.
