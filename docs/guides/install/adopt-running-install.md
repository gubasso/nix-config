# Install flow: adopt a running NixOS install

**TL;DR** — You already booted a fresh stock NixOS. Enable flakes → get the repo
→ derive the host age key from the SSH host key → `nixos-rebuild switch --flake
.#<host>`.

> Use this when NixOS is already installed and booting and you want to adopt it
> in place. If the disk is **not** partitioned to this repo's LUKS-on-LVM layout,
> see the caveat at the bottom. `<host>` is `orion` or `lyra`.

## 1. Enable flakes

Add to `/etc/nixos/configuration.nix` and rebuild once, or set ad hoc:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```
```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```
## 2. Set the hostname to match the flake

`--flake .#orion` requires `networking.hostName = "orion"`. If the stock install
used a different name, either rename it or build the matching host attribute.

## 3. Get this repo

```bash
nix shell nixpkgs#git
git clone https://gitlab.com/gubasso.g/nix-config.git
cd nix-config
```
## 4. Reconcile hardware

This repo's per-host `modules/hardware/<profile>.nix` + disko already describe
the machine, so you normally do **not** commit a generated
`hardware-configuration.nix`. If you want to diff against what the installer
detected:

```bash
sudo nixos-generate-config --show-hardware-config
```
Keep: anything genuinely new (extra kernel modules for this unit). **Drop**:
`fileSystems.*`, `swapDevices`, and `boot.loader.*` device lines — disko owns
those. Fold real additions into `modules/hardware/<profile>.nix`.

## 5. Derive the host age key from the SSH host key

The installer already generated `/etc/ssh/ssh_host_ed25519_key`. Convert it to an
age key so sops can decrypt (no key material leaves the machine):

```bash
nix shell nixpkgs#ssh-to-age nixpkgs#age
sudo mkdir -p /var/lib/sops-nix
sudo sh -c 'ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > /var/lib/sops-nix/key.txt'
# The matching recipient (age1...) for .sops.yaml:
sudo ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```
Then, in the repo:

1. Put the `age1…` recipient into `.sops.yaml` (replace `&<host>_age`).
2. `sops updatekeys secrets/<host>/<file>.yaml` for each existing secret.

(No secrets are declared yet, so you can also defer this until you add the first
one — the first switch below works without a key.)

## 6. Switch

```bash
sudo nixos-rebuild switch --flake .#<host>
```
This activates the config: hostname, users, packages, the dwm session, and
Home Manager for the host user. Home Manager activation logs live under
`~/.local/state/home-manager/`.

## Caveat: disk layout mismatch

`nixos-rebuild switch` does **not** repartition. If the running install's disk
layout differs from this repo's disko layout (LUKS-on-LVM), you have two options:

- **Match the repo (destructive):** back up data, then follow
  [disko-from-iso.md](disko-from-iso.md) to reformat — this wipes the disk.
- **Keep the current layout:** adapt `hosts/<host>/disko.nix` to describe the
  existing partitions, or temporarily carry the installer's `fileSystems` and
  skip disko for this host.

Running `disko --mode destroy,format,mount` against an already-running system is
destructive — never do it to adopt an install with data you want to keep.
