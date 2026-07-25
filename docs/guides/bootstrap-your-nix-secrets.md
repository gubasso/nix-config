# Bootstrap your nix-secrets (consumer flake)

**TL;DR** — Create a private flake that imports `nix-config`, then define one
`mkHost` call per machine. The consumer holds hosts, identity, assets, and
secrets; this framework holds everything shared.

## 1. Minimal consumer `flake.nix`

```nix
{
  inputs.nix-config.url = "github:gubasso/nix-config";

  outputs = { self, nix-config, ... }: {
    nixosConfigurations.myhost = nix-config.lib.mkHost {
      hostname = "myhost";
      username = "me";
      hostModule = ./hosts/myhost;          # default.nix in that dir
      homeModule = ./hosts/myhost/home.nix;
      # Your private-bearing Home Manager apps are self-contained under your own
      # home/apps/ and imported as extra modules (per-app atomicity, ADR-0020).
      extraHomeModules = [ ./home/apps ];
      hostSettings = { dpi = 192; scale = 2; };
    };
  };
}
```

Each app is atomic: a public app is imported from `nix-config`, and any app with a
private part lives wholly in your own `home/apps/<app>/`. `mkHost` still accepts
`publicAppsDir`/`privateAppsDir` (defaulting to this repo's `home/apps` and
`null`), but they no longer split a single app across the two repos.

The consumer needs **only** `nix-config` as an input — nixpkgs, home-manager,
disko, sops-nix, and nixos-hardware all arrive transitively through it. `mkHost`
runs against `nix-config`'s pinned nixpkgs.

## 2. Per-host directory

`hosts/myhost/default.nix` — the only shared thing it imports is its hardware
profile (local to the consumer). Everything else (`base`, `boot`, `users`,
`secrets`, `power`, `audio`, `network`, `session`, home base) is injected by
`mkHost`.

```nix
{ pkgs, hostname, username, ... }:
{
  imports = [
    ./disko.nix
    ./packages.nix
    ../../modules/hardware/myhost.nix       # real bus IDs live here (private)
  ];

  networking.hostName = hostname;
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bashInteractive;
  };
  system.stateVersion = "25.11";
}
```
`hosts/myhost/disko.nix` — a thin call into the injected `mkDisko`
(from `specialArgs`, **not** a relative import):

```nix
{ mkDisko, diskDevice ? "/dev/nvme0n1", luksPasswordFile ? null, ... }:
mkDisko {
  device = diskDevice;
  vgName = "myhostvg";
  diskName = "myhost-system";
  inherit luksPasswordFile;
}
```

`hosts/myhost/home.nix` — the shared home base is injected, so this only holds
host-only extras:

```nix
{ ... }: { }
```
## 3. Assets

Put your dotfiles under `home/apps/<app>/` with the owning app module
expect: `bash/hosts/<hostname>.bash`, `starship/`, `nvim/`, `yazi/`, `rofi/`,
`dunst/`, `picom/`, `gammastep/config.ini`, `browser/`, `environment.d/`,
`kwallet/`, `bin/`, `xsecurelock/`, `profile`. See
[reference/mk-host.md](../reference/mk-host.md) for the full list the modules read.

## 4. Secrets

Create a `.sops.yaml` in the consumer with your own age recipients and creation
rules, then add encrypted files under `secrets/<host>/`. The `sops-nix` module is
already injected by `mkHost`. A minimal per-host rule looks like:

```yaml
keys:
  - &myhost age1replace-with-your-real-host-recipient
creation_rules:
  - path_regex: secrets/myhost/[^/]+\.yaml$
    key_groups:
      - age:
          - *myhost
```

This framework's own `.sops.yaml` is an intentionally empty placeholder
(`keys: []`, `creation_rules: []`); the consumer owns the concrete recipients.

Before tracking secret changes, run the plaintext guard from the `nix-config`
checkout:

```bash
scripts/check-no-plaintext-secrets.sh secrets
```

## 5. Build

```bash
sudo nixos-rebuild switch --flake .#myhost
```
Local dev before this framework is pushed anywhere:

```bash
nixos-rebuild build --flake .#myhost \
  --override-input nix-config path:/path/to/nix-config
```
