# Install flow: disko from the NixOS ISO

**TL;DR** — Boot the ISO → get the repo → `disko` partitions/formats/mounts →
`nixos-install` → set password → reboot. Age key is set up after, when you add
the first secret.

> **Destructive.** `disko` wipes the target disk. Verify the device with `lsblk`
> before you run it. `<host>` is `orion` or `lyra`.

## 1. Boot & network

Boot the NixOS installer ISO. Get networking (Ethernet auto; Wi-Fi via
`nmtui` / `wpa_supplicant`). Become root: `sudo -i`.

## 2. Enable flakes + get tools

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
nix shell nixpkgs#git nixpkgs#gitMinimal   # git for the clone
```
## 3. Get this repo onto the machine

```bash
git clone https://gitlab.com/gubasso.g/nix-config.git
cd nix-config
```
(Private repo — authenticate with a GitLab token/deploy key, or copy the tree in
over `scp`/USB if the installer has no credentials.)

## 4. Confirm the target disk

```bash
lsblk
# The disko layout targets /dev/nvme0n1 by default. If the real device differs,
# edit hosts/<host>/disko.nix (diskDevice) or the flake's mkHost diskDevice.
```
## 5. Partition, format, mount with disko

```bash
sudo nix run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake .#<host>
```
- disko reads `config.disko.devices` from `nixosConfigurations.<host>`.
- LUKS is interactive here (the metal config keeps `luksPasswordFile = null`), so
  you will be prompted to **set the LUKS passphrase**.
- Result: the new filesystems are mounted under `/mnt` (ESP at `/mnt/boot`).

## 6. Install

```bash
sudo nixos-install --flake .#<host>
```
`nixos-install` picks up the disko mounts under `/mnt`, builds the system, and
prompts for the **root password** at the end.

## 7. First boot

```bash
reboot
```
Remove the ISO. Log in as root (or the host user once you set its password):

```bash
sudo passwd <user>          # gubasso on orion, gbasso on lyra
```
## 8. Set up the age key (when you add secrets)

No secrets are declared yet, so the install above needed no key. When you add the
first sops secret, create the host key and register its recipient:

```bash
# On the target, generate the host age key:
sudo mkdir -p /var/lib/sops-nix
sudo nix run nixpkgs#age -- age-keygen -o /var/lib/sops-nix/key.txt
sudo nix run nixpkgs#age -- age-keygen -y /var/lib/sops-nix/key.txt   # prints the recipient age1...
```
Then, in a checkout of this repo:

1. Put that `age1…` recipient into `.sops.yaml` (replace `&<host>_age`).
2. `sops updatekeys secrets/<host>/<file>.yaml` for each secret.
3. Declare the secret in `modules/system/secrets.nix`-style config (in this repo,
   per `nix-config`'s example), commit, and `nixos-rebuild switch --flake .#<host>`.

## Alternative: nixos-anywhere (remote, one shot)

From another machine, provision over SSH (kexec → disko → install → reboot):

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#<host> root@<target-ip>
```
Use `.#<host>-vmtest` with `--vm-test` to dry-run the whole thing in a VM first.
