{ inputs }:
_final: prev: {
  dwm = import ../pkgs/dwm {
    pkgs = prev;
    inherit inputs;
  };
  dwm-session = import ../pkgs/dwm-session { pkgs = prev; };

  # Assemble a config directory as REAL files inside a single store path, so it
  # can be deployed as ONE whole-directory symlink (like ~/.config/nvim) rather
  # than a real dir full of per-file store symlinks. This is the canonical fix
  # for any PURE-CONFIG dir that a dctl devcontainer bind-mounts: the container
  # has its own /nix, and Docker dereferences a whole-dir symlink source at
  # mount time (so it resolves inside the container), whereas per-file symlinks
  # inside a mounted real dir dangle against the foreign /nix. Copying real
  # files keeps HM's GC/rollback/immutability while surviving the bind-mount.
  # `publicAssetsDir`'s `<name>` subtree is the base; the private consumer's
  # `<name>` subtree, when present, is overlaid on top (later wins). Either side
  # may be absent (missing dir or null) — e.g. purely-private configs pass a
  # public base with no `<name>` subtree, purely-public ones pass privateAssetsDir
  # = null. Only for pure config: state belongs in XDG_STATE_HOME and secrets in
  # sops — see nix-secrets docs/decisions/ADR-0010 and docs/reference/config-dir-deploy.md.
  mkRealConfigDir =
    name: publicAssetsDir: privateAssetsDir:
    let
      pub =
        if publicAssetsDir != null && builtins.pathExists (publicAssetsDir + "/${name}") then
          publicAssetsDir + "/${name}"
        else
          null;
      priv =
        if privateAssetsDir != null && builtins.pathExists (privateAssetsDir + "/${name}") then
          privateAssetsDir + "/${name}"
        else
          null;
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
