# Disko From ISO

This public guide documents the shape of the workflow only. Concrete disk
devices, volume groups, host attributes, users, and recipients are private
consumer data.

Placeholder flow:

```bash
git clone <private-consumer-url> <private-consumer>
cd <private-consumer>

# Review private docs and verify the disk with lsblk before destructive steps.
nix run github:nix-community/nixos-anywhere -- --flake .#<host> <user>@<target>
```

Do not run destructive install commands from the public framework repo.
