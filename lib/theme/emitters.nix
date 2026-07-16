# Pure emitters: transform a resolved theme attrset into each app's native color
# format. This is the Nix-native equivalent of a design-token transform pipeline
# (one SoT → many outputs) with zero external tooling. See docs/reference/theming.md.
{ lib }:
rec {
  # base16 slot order for terminal ANSI color0..color15 (the canonical
  # base16 → 16-color-terminal mapping used by kitty and dwm alike).
  ansiSlots = [
    "base00"
    "base08"
    "base0B"
    "base0A"
    "base0D"
    "base0E"
    "base0C"
    "base05"
    "base03"
    "base08"
    "base0B"
    "base0A"
    "base0D"
    "base0E"
    "base0C"
    "base07"
  ];

  # Resolve a semantic role name (e.g. "accent") OR a raw slot name (e.g.
  # "base0E") to its hex string. Semantic names win; unknown names are treated
  # as raw palette slots.
  colorOf = theme: name: theme.palette.${theme.semantic.${name} or name};

  # "#RRGGBB" -> "R;G;B" (decimal), for truecolor SGR escapes (\033[38;2;R;G;Bm).
  # Nix has no hex parser, so map digits by hand.
  hexToRgb =
    hex:
    let
      s = lib.removePrefix "#" hex;
      digit =
        c:
        {
          "0" = 0;
          "1" = 1;
          "2" = 2;
          "3" = 3;
          "4" = 4;
          "5" = 5;
          "6" = 6;
          "7" = 7;
          "8" = 8;
          "9" = 9;
          a = 10;
          b = 11;
          c = 12;
          d = 13;
          e = 14;
          f = 15;
          A = 10;
          B = 11;
          C = 12;
          D = 13;
          E = 14;
          F = 15;
        }
        .${c};
      pair = i: digit (builtins.substring i 1 s) * 16 + digit (builtins.substring (i + 1) 1 s);
    in
    "${toString (pair 0)};${toString (pair 2)};${toString (pair 4)}";

  # kitty color theme (the `current-theme.conf` include target).
  mkKittyTheme =
    theme:
    let
      c = colorOf theme;
      ansi = lib.imap0 (i: slot: "color${toString i}            ${theme.palette.${slot}}") ansiSlots;
    in
    ''
      # Generated from theme "${theme.meta.name}" by nix-config lib/theme. Do not edit.
      foreground              ${c "fg"}
      background              ${c "bg"}
      selection_foreground    ${c "bg"}
      selection_background    ${c "accent"}
      cursor                  ${c "accent"}
      cursor_text_color       ${c "bg"}
      url_color               ${c "info"}
      active_border_color     ${c "accent"}
      inactive_border_color   ${c "muted"}
      active_tab_background    ${c "bg"}
      active_tab_foreground    ${c "fg"}
      inactive_tab_background  ${c "surface"}
      inactive_tab_foreground  ${c "muted"}
      tab_bar_background       ${c "bg"}
      ${lib.concatStringsSep "\n" ansi}
    '';

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
