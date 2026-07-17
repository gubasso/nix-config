# shell-core-specific theme emitter: the bash UI palette. Composed from the
# shared color-token primitives in lib/theme (ADR-0018). A plain helper imported
# by ./default.nix — NOT auto-loaded as an HM module.
{ themeLib }:
let
  inherit (themeLib) colorOf hexToRgb;
in
{
  # bash UI palette (ADR-0002 single-palette source of truth): role -> truecolor
  # SGR escape, derived from the theme. Sourced early by shell-core so bebash and
  # scripts read __UI_SGR. Respects NO_COLOR and non-tty output.
  mkBashPalette =
    theme:
    let
      c = colorOf theme;
      sgr = role: "\\033[38;2;${hexToRgb (c role)}m";
      sgrBold = role: "\\033[1;38;2;${hexToRgb (c role)}m";
    in
    ''
      # Generated from theme "${theme.meta.name}" by nix-config lib/theme. Do not edit.
      # ADR-0002: role -> truecolor SGR, sourced from the active theme palette.
      declare -gA __UI_SGR

      __ui_use_color() {
        [ -z "''${NO_COLOR:-}" ] && [ -t 1 ]
      }

      if __ui_use_color; then
        __UI_SGR=(
          [error]=$'${sgr "error"}'
          [warn]=$'${sgr "warn"}'
          [info]=$'${sgr "info"}'
          [ok]=$'${sgr "success"}'
          [head]=$'${sgrBold "info"}'
          [accent]=$'${sgr "accent"}'
          [muted]=$'${sgr "muted"}'
          [reset]=$'\033[0m'
        )
      else
        __UI_SGR=(
          [error]= [warn]= [info]= [ok]= [head]= [accent]= [muted]= [reset]=
        )
      fi
    '';
}
