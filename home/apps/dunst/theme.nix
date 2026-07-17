# dunst-specific theme emitter: the color drop-in fragment. Composed from the
# shared color-token primitive in lib/theme (ADR-0018). A plain helper imported
# by ./default.nix — NOT auto-loaded as an HM module.
{ themeLib }:
let
  inherit (themeLib) colorOf;
in
{
  # dunst colors as a dunstrc.d/ drop-in fragment (dunst >= 1.7 merges
  # ~/.config/dunst/dunstrc.d/*.conf over the base dunstrc). Only the color
  # settings live here; the structural dunstrc stays static.
  mkDunstColors =
    theme:
    let
      c = colorOf theme;
    in
    ''
      # Generated from theme "${theme.meta.name}" by nix-config lib/theme. Do not edit.
      [global]
          frame_color = "${c "accent"}"

      [urgency_low]
          background = "${c "surface"}"
          foreground = "${c "muted"}"
          frame_color = "${c "accent"}"

      [urgency_normal]
          background = "${c "bg"}"
          foreground = "${c "fg"}"
          frame_color = "${c "accent"}"

      [urgency_critical]
          background = "${c "bg"}"
          foreground = "${c "fg"}"
          frame_color = "${c "error"}"
    '';
}
