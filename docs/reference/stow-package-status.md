# Stow Package Status

Phase 6 reconciliation for `/workspaces/.dotfiles`. Old Stow remains the
runtime checklist until live-host switches verify each package.

| Package | Status | Notes |
| --- | --- | --- |
| `arch-update` | blocked | Arch-only tool for `nova`; needs live-host decision. |
| `bash` | ported | Host fragments for all four hosts are in `home/assets/bash/hosts/`. |
| `bebash` | out-of-scope | External project config; only host fragments were ported. |
| `bin` | partial | Active browser, askpass, and kitty helper scripts ported; remaining scripts need inventory. |
| `brave` | partial | Shared launcher and browser flags are ported; profile setup hook is live-host work. |
| `brave-nova` | partial | Folded into shared browser assets; live verification remains. |
| `brave-tumblesuse` | partial | Folded into shared browser assets; live verification remains. |
| `browser-nova` | partial | Shared browser assets ported; host-specific launch verification remains. |
| `browser-tumblesuse` | partial | Shared browser assets ported; host-specific launch verification remains. |
| `claude` | blocked | Credential/cache split requires user review. |
| `claude-session` | out-of-scope | Agent/session infra, not core host config. |
| `codex-session` | out-of-scope | Agent/session infra, not core host config. |
| `console-keymap` | blocked | System-scope Arch/NixOS keymap delivery needs root/live-host validation. |
| `dctl` | blocked | Tool templates need active-use decision. |
| `desktop` | blocked | Desktop database hook needs activation design after live switch. |
| `direnv` | ported | `direnvrc` and `direnv.toml` are managed by HM. |
| `dunst` | ported | `dunstrc` is managed by HM. |
| `dwm` | partial | `dwm-session` package owns session files; Xresources/sxhkd/status need reconciliation. |
| `editorconfig` | retired | Repo tooling, not user runtime config. |
| `gammastep` | ported | Config is managed by HM. |
| `gemini` | blocked | May contain agent credentials; requires user split. |
| `git` | ported | `allowed_signers` is managed by HM. |
| `gpg` | partial | Non-secret `gpg-agent.conf` ported; private keys require sops export. |
| `gpg-tumblesuse` | blocked | Host pinentry/env requires live openSUSE check. |
| `greetd` | blocked | System-scope NixOS module validation remains. |
| `greflector` | retired | No active runtime config found. |
| `keepassxc` | blocked | Hook-only behavior needs live-host decision. |
| `kitty` | ported | Kitty config and helper scripts are managed by HM. |
| `kwallet` | ported | KWallet config and askpass helper are managed by HM. |
| `nextcloud` | blocked | Account data is not Nix-managed; stable config needs user decision. |
| `nix-config` | blocked | Legacy Nix client config needs separate non-NixOS install note. |
| `npm` | blocked | User-global prefix hook needs active-use decision. |
| `nvim` | ported | Full nvim config tree is managed by HM. |
| `opencode` | blocked | Agent/tool config requires credential split. |
| `picom` | ported | `picom.conf` is managed by HM. |
| `pipewire` | retired | NixOS audio module owns system audio. |
| `rclone` | blocked | Credentials require sops; only `.rcloneignore` is non-secret candidate. |
| `riptask` | blocked | Active-use decision required. |
| `rofi` | ported | Config, `rofimoji.rc`, and themes are managed by HM. |
| `rofi-nova` | partial | Host font scaling should fold into host settings after live check. |
| `rofi-tumblesuse` | partial | Host font scaling should fold into host settings after live check. |
| `shell` | ported | Profile and environment fragments are managed by HM. |
| `ssh` | partial | Generic non-secret SSH config ported; keys require sops. |
| `ssh-tumblesuse` | blocked | Host-specific agent socket and secrets require live openSUSE check. |
| `starship` | ported | Starship configs are managed by HM. |
| `stow` | retained | Checklist remains until final decommission. |
| `suse-cloud-regionsrv-integration-tester` | blocked | Work-specific sensitive config requires user split. |
| `suse-lsyncd` | blocked | Work-specific sensitive config requires user split. |
| `suse-reg-tests` | blocked | Work-specific sensitive config requires user split. |
| `theme` | retired | No active runtime config found. |
| `thunderbird` | blocked | Signatures can port later; account credentials stay out of repo. |
| `tlp-nova` | partial | NixOS hardware profile covers future `orion`; Arch `nova` delivery remains native. |
| `xbanish-nova` | blocked | Hook-only behavior needs live-host service decision. |
| `xbanish-tumblesuse` | blocked | User service needs live openSUSE validation. |
| `xdg-desktop-portal-nova` | blocked | Needs dwm live-host validation. |
| `xorg-input` | blocked | System-scope input config needs NixOS/native-host split. |
| `xsecurelock` | ported | Environment config is managed by HM; xss-lock hook retirement needs live check. |
| `xsecurelock-sleep` | blocked | Sleep integration needs live-host decision. |
| `xsettingsd` | retired | Generated by `modules/home/graphics.nix`. |
| `yazi` | ported | Config, flavor, and `package.toml` are managed by HM. |
| `yt-dlp` | ported | Config is managed by HM. |

Hook-bearing packages were inspected during migration. Any status other than
`ported` or `retired` must stay stowed until a live-host switch verifies the
replacement or confirms retirement.
