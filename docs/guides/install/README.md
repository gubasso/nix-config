# Install Guides

Public install guides are framework examples only. Use placeholders such as
`<private-consumer>`, `<host>`, `<user>`, `<disk>`, and `<volume-group>`.

Concrete machine inventories, disk names, users, recipients, and activation
commands live in the private consumer repo.

Typical human-only validation order:

```bash
cd <public-framework>
nix fmt
nix flake check

cd <private-consumer>
nix flake check --override-input nix-config path:<public-framework>
sudo nixos-rebuild build --flake .#<host>
home-manager build --flake .#<user>@<host>
```
