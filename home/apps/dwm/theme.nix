# dwm-specific theme emitter: the Xresources color block. Composed from the
# shared color-token primitives in lib/theme (ADR-0018). A plain helper imported
# by ./default.nix — NOT auto-loaded as an HM module.
{ lib, themeLib }:
let
  inherit (themeLib) colorOf ansiSlots;
in
{
  # dwm colors as an Xresources block (the fork reads these via loadxrdb():
  # dwm.{norm,sel}{bg,fg,border}color and color0..color15).
  mkDwmXresources =
    theme:
    let
      c = colorOf theme;
      ansi = lib.imap0 (i: slot: "color${toString i}: ${theme.palette.${slot}}") ansiSlots;
    in
    ''
      ! Generated from theme "${theme.meta.name}" by nix-config lib/theme. Do not edit.
      dwm.normbgcolor:     ${c "bg"}
      dwm.normfgcolor:     ${c "fg"}
      dwm.normbordercolor: ${c "border"}
      dwm.selbgcolor:      ${c "accent"}
      dwm.selfgcolor:      ${c "bg"}
      dwm.selbordercolor:  ${c "accent"}
      Xcursor.theme: ${theme.cursor.theme}
      Xcursor.size: ${toString theme.cursor.size}
      ${lib.concatStringsSep "\n" ansi}
    '';
}
