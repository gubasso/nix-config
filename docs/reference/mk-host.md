# Reference — `lib.mkHost`

Host factory. Curried: bound to `{ inputs }` by this flake, then called with a
per-host attrset. Returns a `nixpkgs.lib.nixosSystem`. Source: `lib/mk-host.nix`.

## Arguments

| Arg | Required | Default | Purpose |
| --- | --- | --- | --- |
| `hostname` | yes | — | `networking.hostName`; also a `specialArg`. |
| `username` | yes | — | Primary user; threaded to system + Home Manager. |
| `hostModule` | yes | — | Path/module for the host (`hosts/<name>/default.nix`): hardware import, disko, packages, user, stateVersion. |
| `homeModule` | yes | — | Path/module for host-only Home Manager extras (`hosts/<name>/home.nix`). The shared home base is injected separately. |
| `assetsDir` | yes | — | Path to the consumer's Home Manager asset tree; home modules read files as `assetsDir + "/…"`. |
| `hostSettings` | no | `{ }` | Per-host data; `{ dpi, scale }` consumed by `modules/home/graphics.nix`. |
| `system` | no | `"x86_64-linux"` | Platform double. |
| `diskDevice` | no | `"/dev/nvme0n1"` | Block device for disko; override to the VM disk for `--vm-test`. |
| `luksPasswordFile` | no | `null` | LUKS password file; `null` = interactive askPassword on metal. |
| `extraModules` | no | `[ ]` | Extra NixOS modules for this host. |

## What mkHost injects

A consumer host imports **none** of these — `mkHost` adds them:

- System: `base`, `boot`, `users`, `secrets`, `power`, `audio`, `network`,
  `session`, `vm`.
- Inputs: `disko`, `sops-nix`, `home-manager` NixOS modules.
- Overlay: `overlays/default.nix` (adds `dwm`, `dwm-session`).
- Home Manager base: `modules/home/common.nix` + the consumer's `homeModule`.

## specialArgs (system modules)

`inputs`, `hostname`, `username`, `diskDevice`, `luksPasswordFile`,
`hostSettings`, `mkDisko`.

## extraSpecialArgs (Home Manager modules)

`inputs`, `hostname`, `username`, `hostSettings`, `assetsDir`.

## Asset paths the home modules read (under `assetsDir`)

`bash/hosts/<hostname>.bash`, `starship/starship.toml`,
`starship/starship-tty.toml`, `nvim/`, `yazi/{yazi.toml,init.lua,theme.toml}`,
`yazi/flavors/everforest-medium.yazi`, `bin/{browser-launcher,brave-launcher,ssh-askpass-rofi}`,
`rofi/{config.rasi,themes/everforest.rasi}`, `dunst/dunstrc`, `picom/picom.conf`,
`gammastep/config.ini`, `xsecurelock/env.conf`,
`browser/{env.sh,flags.d/defaults.conf,vulkan/disabled-icd.d/*}`,
`autorandr/README.md`, `environment.d/*.conf`, `profile`, `kwallet/kwalletrc`.
