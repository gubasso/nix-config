# starship-specific theme emitter: the [palettes.theme] table. Composed from the
# shared color-token primitive in lib/theme (ADR-0018). A plain helper imported
# by ./default.nix — NOT auto-loaded as an HM module.
{ themeLib }:
let
  inherit (themeLib) colorOf;
in
{
  # starship [palettes.theme] table. The prompt's styles reference standard
  # color names; remapping those names to theme hex here recolors the whole
  # prompt without touching a single style. The module also emits the
  # top-level `palette = "theme"` selector.
  mkStarshipPalette =
    theme:
    let
      c = colorOf theme;
    in
    ''
      # Generated from theme "${theme.meta.name}" by nix-config lib/theme. Do not edit.
      [palettes.theme]
      blue = "${c "info"}"
      red = "${c "error"}"
      green = "${c "success"}"
      cyan = "${c "info"}"
      yellow = "${c "warn"}"
      purple = "${c "accent"}"
      bright-purple = "${c "accent"}"
      bright-black = "${c "muted"}"
    '';
}
