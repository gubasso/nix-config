# rofi-specific theme emitters: the color block and the pango font string.
# Composed from the shared color-token primitive in lib/theme (ADR-0018). A plain
# helper imported by ./default.nix — NOT auto-loaded as an HM module.
{ themeLib }:
let
  inherit (themeLib) colorOf;
in
{
  # rofi color block. Consumed by the shared layout (home/apps/rofi/layout.rasi)
  # which references these canonical variable names.
  mkRofiColors =
    theme:
    let
      c = colorOf theme;
    in
    ''
      /* Generated from theme "${theme.meta.name}" by nix-config lib/theme. Do not edit. */
      * {
        bg:      ${c "bg"};
        surface: ${c "surface"};
        overlay: ${c "overlay"};
        muted:   ${c "muted"};
        fg:      ${c "fg"};
        accent:  ${c "accent"};
        border:  ${c "border"};
        error:   ${c "error"};
        warn:    ${c "warn"};
        success: ${c "success"};
        info:    ${c "info"};

        background-color: transparent;
        text-color:       @fg;
      }
    '';

  # rofi/pango font string ("Family Size") for programs.rofi.font. `font` is a
  # resolved { family; size; } from themeLib.fontOf.
  mkRofiFont = font: "${font.family} ${toString font.size}";
}
