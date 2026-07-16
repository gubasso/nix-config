{ inputs }:
_final: prev: {
  dwm = import ../pkgs/dwm {
    pkgs = prev;
    inherit inputs;
  };
  dwm-session = import ../pkgs/dwm-session { pkgs = prev; };

  # fzf-tab-completion (lincheney's bash port) — not in nixpkgs; vendored under
  # pkgs/ and exposed here so the fzf app module can source it from the store.
  fzf-tab-completion = import ../pkgs/fzf-tab-completion { pkgs = prev; };

  # Theme library (resolver + emitters) over the public theme registry. Exposed
  # here so any Home Manager app module can resolve `hostSettings.theme` and emit
  # its native color config without a cross-flake path import. Pure functions of
  # a theme attrset — no build inputs. See lib/theme and docs/reference/theming.md.
  themeLib = import ../lib/theme { inherit (prev) lib; };

  # Assemble a config directory as REAL files inside a single store path, so it
  # can be deployed as ONE whole-directory symlink (like ~/.config/nvim) rather
  # than a real dir full of per-file store symlinks. This is the canonical fix
  # for any PURE-CONFIG dir that a dctl devcontainer bind-mounts: the container
  # has its own /nix, and Docker dereferences a whole-dir symlink source at
  # mount time (so it resolves inside the container), whereas per-file symlinks
  # inside a mounted real dir dangle against the foreign /nix. Copying real
  # files keeps HM's GC/rollback/immutability while surviving the bind-mount.
  # The caller passes explicit base/overlay config directories. Either side may
  # be absent (missing dir or null). Only for pure config: state belongs in
  # XDG_STATE_HOME and secrets in sops — see nix-secrets docs/decisions/ADR-0010
  # and docs/reference/config-dir-deploy.md.
  mkRealConfigDir =
    name: pubDir: privDir:
    let
      pub = if pubDir != null && builtins.pathExists pubDir then pubDir else null;
      priv = if privDir != null && builtins.pathExists privDir then privDir else null;
    in
    prev.runCommandLocal "${name}-config" { } (
      ''
        mkdir -p "$out"
      ''
      + prev.lib.optionalString (pub != null) ''
        cp -rL --no-preserve=mode ${pub}/. "$out/"
      ''
      + prev.lib.optionalString (priv != null) ''
        cp -rLf --no-preserve=mode ${priv}/. "$out/"
      ''
    );
}
