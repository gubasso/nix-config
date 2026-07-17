# Purple City — a neon-noir purple metropolis, dark. The canonical reference
# theme (see ./docs for the brand-book). Palette seeded from the original
# hand-authored rofi theme; base16 slots + a semantic-alias layer feed every app
# through lib/theme emitters. Schema: docs/reference/theming.md.
{
  meta = {
    name = "purple-city";
    label = "Purple City";
    polarity = "dark";
    blurb = "Neon-noir purple metropolis — deep violet nights lit by magenta signage.";
  };

  # Tier 1 — primitives (base16). base00 darkest bg … base07 brightest fg;
  # base08..base0F accent hues (red/orange/yellow/green/cyan/blue/magenta/brown).
  palette = {
    base00 = "#010005";
    base01 = "#16042D";
    base02 = "#2C094C";
    base03 = "#B9A6CC";
    base04 = "#D9CCE8";
    base05 = "#F5F0FF";
    base06 = "#F7F2FF";
    base07 = "#FFFFFF";
    base08 = "#FF4D8D";
    base09 = "#F2D26B";
    base0A = "#FFD166";
    base0B = "#3FE1B0";
    base0C = "#7AA2F7";
    base0D = "#8AB4FF";
    base0E = "#C89DEA";
    base0F = "#E65FEB";
  };

  # Tier 2 — semantic aliases (role -> slot name). Apps read roles; base16 backs
  # them. accent is the theme's signature magenta.
  semantic = {
    bg = "base00";
    surface = "base01";
    overlay = "base02";
    muted = "base03";
    fg = "base05";
    emphasis = "base07";
    border = "base02";
    accent = "base0E";
    error = "base08";
    warn = "base09";
    success = "base0B";
    info = "base0C";
  };

  # Typography SoT (design tokens): the shared default font set. Spread-and-
  # override (`// { ... }`) or inline a bespoke block to diverge. See
  # themes/_shared/typography.nix and docs/reference/theming.md.
  typography = import ../_shared/typography.nix;

  # X cursor theme + size (fed to XCURSOR_THEME/XCURSOR_SIZE by
  # modules/home/env-shell.nix). Dark themes use the classic (dark) Bibata.
  cursor = {
    theme = "Bibata-Modern-Classic";
    size = 32;
  };

  # Sibling schemes — name references only. A host picks one per app via
  # `hostSettings.appSchemes.<app>`; the app loads it natively (nvim colorscheme
  # plugin). No color injection. Values are the nvim colorscheme keys actually
  # installed in the consumer (see home/apps/nvim/.../colorschemes.lua). Apps
  # driven by the emitted palette (kitty, rofi, dwm) need no sibling entry.
  associatedSchemes = {
    nvim = [ "catppuccin" ];
  };
}
