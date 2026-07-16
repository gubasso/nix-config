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
      ${lib.concatStringsSep "\n" ansi}
    '';
}
