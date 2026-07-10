# Hosts

This public repo intentionally contains no concrete host inventory.

Private consumers define their own:

- host modules under `hosts/<host>/`
- standalone Home Manager modules under `hosts/<host>/home.nix`
- private hardware profiles under their own module tree
- `nixosConfigurations.<host>` and `homeConfigurations."<user>@<host>"`

Use `lib.mkHost` and `lib.mkHomeHost` from this framework with
`publicAssetsDir` pointing at this repo's `home/assets` and `privateAssetsDir`
pointing at the consumer's private asset tree.
