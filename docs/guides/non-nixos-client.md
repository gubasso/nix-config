# Non-NixOS Nix Client Notes

Legacy client files from `/workspaces/.dotfiles/nix-config/.config/nix` are archived here for the manual non-NixOS cutover.

| Legacy file | Migrated reference |
| --- | --- |
| `.config/nix/nix.conf` | `docs/guides/legacy-nix-client/nix.conf` |
| `.config/nix/host-flake/` | `docs/guides/legacy-nix-client/host-flake/` |

Do not treat the archived host flake as the runtime source of truth unless a human chooses a separate non-NixOS checkout model. The consolidated `nix-config` flake remains the intended configuration source of truth.
