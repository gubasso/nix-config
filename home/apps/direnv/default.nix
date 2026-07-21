# direnv and nix-direnv, plus dctl one-shot env export support.
{
  lib,
  pkgs,
  ...
}:

let
  # nix-direnv's stdlib as a REAL overlay file so the whole-dir carries
  # lib/hm-nix-direnv.sh (direnv auto-sources ~/.config/direnv/lib/*.sh). This
  # replaces programs.direnv.nix-direnv.enable, which would inject the SAME path as
  # its own per-file xdg.configFile symlink — colliding with the whole-dir source
  # here and dangling inside a dctl container besides. Baked as a real file, it
  # keeps working on the host and now survives the container bind-mount too.
  nixDirenvLib = pkgs.runCommandLocal "direnv-nix-direnv-lib" { } ''
    install -Dm644 ${pkgs.nix-direnv}/share/nix-direnv/direnvrc "$out/lib/hm-nix-direnv.sh"
  '';
in
{
  programs.direnv.enable = true;

  # Deploy ~/.config/direnv as ONE whole-directory symlink (the ~/.config/nvim
  # shape) via mkRealConfigDir, so it survives the read-only bind-mount into every
  # dctl devcontainer (base layer) — per-file store symlinks would dangle against
  # the container's own /nix (nix-secrets ADR-0010). ./config holds direnvrc +
  # direnv.toml; the nix-direnv stdlib overlays in as lib/hm-nix-direnv.sh.
  xdg.configFile."direnv".source = lib.mkDefault (
    pkgs.mkRealConfigDir "direnv" ./config nixDirenvLib
  );

  programs.bash.initExtra = ''
    if [[ -n "''${DCTL_SANDBOX:-}" && -n "''${BASH_EXECUTION_STRING:-}" ]]; then
      eval "$(direnv export bash)"
    fi
  '';
}
