# Everforest (Dark, Hard) — a warm, soft, green-based forest palette. Preserves
# the repo's long-standing default look as a first-class SoT theme. Palette from
# Sainnhe Park's Everforest (dark/hard). Schema: docs/reference/theming.md.
{
  meta = {
    name = "everforest";
    label = "Everforest Dark Hard";
    polarity = "dark";
    blurb = "Warm, low-contrast forest greens — easy on the eyes for long sessions.";
  };

  # Tier 1 — primitives (base16), Everforest dark/hard.
  palette = {
    base00 = "#272E33";
    base01 = "#2E383C";
    base02 = "#374145";
    base03 = "#4F5B58";
    base04 = "#859289";
    base05 = "#D3C6AA";
    base06 = "#E0DCC7";
    base07 = "#FDF6E3";
    base08 = "#E67E80";
    base09 = "#E69875";
    base0A = "#DBBC7F";
    base0B = "#A7C080";
    base0C = "#83C092";
    base0D = "#7FBBB3";
    base0E = "#D699B6";
    base0F = "#9DA9A0";
  };

  # Tier 2 — semantic aliases. accent is Everforest's signature green.
  semantic = {
    bg = "base00";
    surface = "base01";
    overlay = "base02";
    muted = "base03";
    fg = "base05";
    emphasis = "base07";
    border = "base02";
    accent = "base0B";
    error = "base08";
    warn = "base09";
    success = "base0B";
    info = "base0D";
  };

  typography = {
    mono = {
      family = "Hack";
      size = 17;
    };
    ui = {
      family = "Inter";
      size = 11;
    };
    glyphs = "Symbols Nerd Font";
    weights = {
      regular = 400;
      medium = 500;
      bold = 700;
    };
  };

  # X cursor theme + size (fed to XCURSOR_THEME/XCURSOR_SIZE by
  # modules/home/env-shell.nix). Dark themes use the classic (dark) Bibata.
  cursor = {
    theme = "Bibata-Modern-Classic";
    size = 32;
  };

  # Sibling schemes — nvim colorscheme keys installed in the consumer. Apps
  # driven by the emitted palette (kitty, rofi, dwm) need no sibling entry.
  associatedSchemes = {
    nvim = [ "everforest" ];
  };
}
