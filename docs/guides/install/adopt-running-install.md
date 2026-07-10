# Adopt A Running Install

This public guide is a placeholder workflow for private consumers.

1. Clone the private consumer repo at `<private-consumer>`.
2. Confirm the target machine's hostname, disk layout, user, and recipients in
   private docs.
3. Use the public framework through the private flake input.
4. Run live build or switch commands only after the private tree is reviewed and
   encrypted secrets are in place.

Example commands are intentionally placeholder-only:

```bash
cd <private-consumer>
nix flake check --override-input nix-config path:<public-framework>
sudo nixos-rebuild build --flake .#<host>
```
