# xsecurelock-specific theme emitter: the env.conf color lines. Composed from the
# shared color-token primitive in lib/theme (ADR-0018). A plain helper imported
# by ./default.nix — NOT auto-loaded as an HM module.
{ themeLib }:
let
  inherit (themeLib) colorOf;
in
{
  # xsecurelock color lines (env.conf fragment). Only the three color knobs are
  # theme-driven; the rest of env.conf stays static.
  mkXsecurelockEnv =
    theme:
    let
      c = colorOf theme;
    in
    ''
      # Generated from theme "${theme.meta.name}" by nix-config lib/theme. Do not edit.
      XSECURELOCK_BACKGROUND_COLOR=${c "bg"}
      XSECURELOCK_AUTH_BACKGROUND_COLOR=${c "surface"}
      XSECURELOCK_AUTH_FOREGROUND_COLOR=${c "fg"}
    '';
}
