# Single source of truth for the font catalogue: token -> { family; pkg; }.
#
#   family : the exact fontconfig family string (verified with fc-scan on the
#            built package — never guessed).
#   pkg    : selects the nixpkgs package, as a function of a package set so this
#            data module stays build-input-free (applied as `pkg pkgs`).
#
# BOTH downstream maps derive from here, so nothing is written twice:
#   - themes/_shared/typography.nix `families`     (token  -> family)  via mapAttrs
#   - lib/theme/fonts.nix          `fontPackagesFor` (family -> package) via mapAttrs'
# Add a font in ONE place here and it becomes a resolvable token AND provisioned.
# The whole set is installed on opt-in hosts by modules/home/fonts.nix. The
# Nerd-patched variant is chosen where one exists (family carries the "Nerd Font"
# suffix), else the plain original family.
{
  # ── Theme base fonts (referenced by typography roles) ──────────────────────
  # coding default (Nerd-patched)
  hack = {
    family = "Hack";
    pkg = p: p.nerd-fonts.hack;
  };
  # UI sans
  inter = {
    family = "Inter";
    pkg = p: p.inter;
  };
  # IBM Plex Mono (tumblesuse kitty/rofi)
  ibmplex = {
    family = "IBM Plex Mono";
    pkg = p: p.ibm-plex;
  };
  # icon glyphs only (kitty symbol_map)
  symbols = {
    family = "Symbols Nerd Font";
    pkg = p: p.nerd-fonts.symbols-only;
  };

  # ── Retro / hacker / terminal + modern-pixel library ───────────────────────
  # MS Cascadia Mono, no ligatures
  cascadia-mono = {
    family = "CaskaydiaMono Nerd Font";
    pkg = p: p.nerd-fonts.caskaydia-mono;
  };
  # 1970s IBM mainframe terminal
  ibm3270 = {
    family = "3270 Nerd Font";
    pkg = p: p.nerd-fonts._3270;
  };
  # classic Linux-console bitmap
  terminus = {
    family = "Terminess Nerd Font";
    pkg = p: p.nerd-fonts.terminess-ttf;
  };
  # crisp multi-size bitmap
  spleen = {
    family = "Spleen 8x16";
    pkg = p: p.spleen;
  };
  # cozy 6x13 pixel w/ icons (vector cut)
  cozette = {
    family = "CozetteVector";
    pkg = p: p.cozette;
  };
  # sharp programmer bitmap
  tamzen = {
    family = "Tamzen";
    pkg = p: p.tamzen;
  };
  # Tamzen's progenitor
  tamsyn = {
    family = "Tamsyn";
    pkg = p: p.tamsyn;
  };
  # dense terminal pixel font
  gohufont = {
    family = "GohuFont 14 Nerd Font";
    pkg = p: p.nerd-fonts.gohufont;
  };
  # iconic 2000s coding bitmap
  proggyclean = {
    family = "ProggyClean Nerd Font";
    pkg = p: p.nerd-fonts.proggy-clean-tt;
  };
  # 1966 optical-scan OCR look
  ocra = {
    family = "OCRA";
    pkg = p: p.ocr-a;
  };
  # modern lo-fi pixel/OCR
  # ★ BEST PICK #1 (aesthetic champion): vector font that nails the OCR/pixel
  #   hacker look yet stays easy on the eyes for long sessions — scales smoothly.
  departure-mono = {
    family = "DepartureMono Nerd Font";
    pkg = p: p.nerd-fonts.departure-mono;
  };
  # 80s squarish, dotted zero
  space-mono = {
    family = "SpaceMono Nerd Font";
    pkg = p: p.nerd-fonts.space-mono;
  };
  # scalable retro code font
  envy-code-r = {
    family = "EnvyCodeR Nerd Font";
    pkg = p: p.nerd-fonts.envy-code-r;
  };
  # old Macintosh "Anonymous 9"
  anonymous-pro = {
    family = "AnonymicePro Nerd Font";
    pkg = p: p.nerd-fonts.anonymice;
  };
  # wibbly, playful Monaco-ish
  fantasque = {
    family = "FantasqueSansM Nerd Font";
    pkg = p: p.nerd-fonts.fantasque-sans-mono;
  };
  # narrow terminal-tuned
  # ★ BEST PICK #3 (most versatile): slender, highly legible, endlessly tunable
  #   retro-terminal vector font — fits more code per line, gentle on the eyes.
  iosevka-term = {
    family = "IosevkaTerm Nerd Font";
    pkg = p: p.nerd-fonts.iosevka-term;
  };
  # legible Comic Sans mono
  comic-mono = {
    family = "Comic Mono";
    pkg = p: p.comic-mono;
  };
  # GitHub superfamily, Krypton face
  # ★ BEST PICK #2 (best balance): mechanical-technical vibe with "texture
  #   healing" that rebalances narrow glyphs — cool + comfortable for long reads.
  monaspace-krypton = {
    family = "MonaspiceKr Nerd Font";
    pkg = p: p.nerd-fonts.monaspace;
  };
  # Minecraft blocky pixel
  monocraft = {
    family = "Monocraft";
    pkg = p: p.monocraft;
  };
  # TTF revival of DOS Fixedsys
  fixedsys = {
    family = "Fixedsys Excelsior 3.01";
    pkg = p: p.fixedsys-excelsior;
  };
  # pixel-style coding font
  pixel-code = {
    family = "Pixel Code";
    pkg = p: p.pixel-code;
  };
  # tall minimal pixel
  scientifica = {
    family = "scientifica";
    pkg = p: p.scientifica;
  };
  # blocky Unicode-art, outline cut
  unscii = {
    family = "unscii";
    pkg = p: p.unscii;
  };
  # designed low-res pixel grid
  undefined-medium = {
    family = "undefined";
    pkg = p: p.undefined-medium;
  };
  # modern multilingual pixel (CJK)
  ark-pixel = {
    family = "Ark Pixel 12px M latin";
    pkg = p: p.ark-pixel-font;
  };
  # 90s hacker bitmap classic
  dina = {
    family = "Dina";
    pkg = p: p.dina-font;
  };
}
