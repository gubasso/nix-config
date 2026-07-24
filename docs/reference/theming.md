# Theming reference

The canonical schema and contracts for the theme system (ADR-0017). For the
"why", see [../explanation/theming-model.md](../explanation/theming-model.md); to
add a theme, see [../guides/authoring-a-theme.md](../guides/authoring-a-theme.md).

## Model

A **theme** is a pure, host-agnostic Nix attrset under `themes/<name>/theme.nix`,
registered in `themes/default.nix`. A host picks one by name; app modules resolve
it and call an emitter to derive their native color config. Nothing host-specific
lives in a theme.

Tiers:

1. **Palette (base16 primitives)** — `base00`…`base0F`.
2. **Semantic aliases** — role names that reference palette slots.
3. **Typography + associated schemes** — fonts and per-app sibling scheme names.

## `theme.nix` schema

```nix
{
  meta = { name; label; polarity;  # "dark" | "light"
           blurb; };
  palette   = { base00 … base0F };  # 16 "#RRGGBB" strings
  semantic  = {                     # role -> base16 slot (resolved in one hop)
    bg surface surface2 overlay muted text_dim fg emphasis border
    accent primary secondary error warn success info urgent;
  };
  typography = {
    families = { <token> = "<fontconfig family>"; … };  # registry of official fonts
    sizes    = { <token> = <int>; … };                   # named size scale (points)
    roles    = { mono   = { family = <fam-token>; size = <size-token>; };
                 ui     = { family; size; };
                 glyphs = { family; };  };                # role -> family+size tokens
    weights  = { regular; medium; bold; };
  };
  associatedSchemes = {             # per-app upstream scheme NAMES (name-ref only)
    nvim  = [ … ];
    kitty = [ … ];
  };
}
```

`name` must equal the directory name. Every `semantic` value must be a
`base00`…`base0F` slot name: `colorOf` resolves a role in a **single hop**
(`palette.${semantic.role}`), so roles do **not** chain to other roles. The full
canonical vocabulary above is **required** in every theme and checked at resolve
time (see [Validation](#validation)).

## base16 semantic-slot standard

| Slots | Meaning |
| --- | --- |
| base00 | background |
| base01 | surface (lighter bg) |
| base02 | overlay / border / selection / **surface2** |
| base03 | muted / comments |
| base04 | dim foreground — **text_dim** |
| base05 | default foreground |
| base06–07 | bright foreground |
| base08 | red — **error** / **urgent** |
| base09 | orange — **warn** |
| base0A | yellow |
| base0B | green — **success** |
| base0C | cyan — **info** |
| base0D | blue |
| base0E | magenta |
| base0F | brown |

`accent`/`primary`/`secondary`/`urgent` are **theme-chosen** roles: they point at
whichever hue carries that intent in the palette (e.g. a green theme aims `accent`
and `primary` at `base0B`, a purple one at `base0E`). `primary` is the signature
action colour (typically the same slot as `accent`); `secondary` is a
complementary hue; `urgent` flags attention (dwm urgent-window borders, dunst
critical notifications) and may share `base08` with `error` or diverge.

Terminal ANSI `color0..15` derive from a fixed base16 slot order (see
`lib/theme/colors.nix:ansiSlots`); `accent`/`success`/`info` etc. are chosen
per theme via the semantic layer, so a green theme points `accent` at `base0B`
and a purple one at `base0E`.

## Validation

`resolve` validates a theme's shape at **eval time** — the declarative analogue of
a JSON Schema, kept in `lib/theme/default.nix` (`validateTheme`) rather than a
separate check derivation. Because every app module resolves the active theme,
any violation surfaces on `nix flake check` / `home-manager switch` with a
theme-named message. The checks (ADR-0019):

- **Required semantic roles** — the full canonical vocabulary must be present.
- **One-hop resolution** — every `semantic` value names a defined palette slot.
- **Palette completeness** — exactly `base00`…`base0F`.
- **Colour format** — every palette value matches `#RRGGBB`.
- **`meta.polarity`** is `"dark"` or `"light"`; **`cursor`** has a string `theme`
  and int `size`.

## `lib/theme` — resolver + token-algebra primitives

Exposed as `pkgs.themeLib` (overlay, for app modules) and `flake.lib.theme`.
`lib/theme` holds only the **shared, app-agnostic token algebra**; the
app-specific string formatters (the `mk*` emitters) live with each app under
`home/apps/<app>/theme.nix` (ADR-0018), composed from these primitives.

Module layout: `default.nix` stitches the registry + `resolve` + `assertAppScheme`
over two primitive modules — `colors.nix` (color algebra: `colorOf`, `hexToRgb`,
`ansiSlots`) and `fonts.nix` (font algebra: `fontOf` + the `fontPackagesFor`
provisioning map). The default font tokens are shared in
`themes/_shared/typography.nix` (imported by each theme's `typography`).

Public `pkgs.themeLib` surface:

- `resolve name` → the theme attrset (throws on unknown name or invalid shape; see [Validation](#validation)).
- `colorOf theme role` → hex for a semantic role or raw slot.
- `hexToRgb "#RRGGBB"` → `"R;G;B"` decimal (for truecolor SGR escapes).
- `ansiSlots` → the base16 slot order backing terminal `color0..15`.
- `fontOf theme { role?; family?; size? }` → resolved `{ family = "<string>";
  size = <int|null>; }`. `family`/`size` may be registry/scale tokens or literal
  values (a literal family string is the escape hatch); an explicit spec value
  overrides the role default. Callers layer precedence by merging attrs before the
  call: `fontOf theme (roleDefault // appDefault // hostOverride)`.
- `assertAppScheme theme app scheme` → validates a host pick is in the theme's
  `associatedSchemes.<app>`; returns the scheme or throws.

Per-app emitters, each in its own `home/apps/<app>/theme.nix` and built from the
primitives above: `mkRofiColors` + `mkRofiFont` (rofi), `mkKittyTheme` +
`mkKittyFont` (kitty), `mkDwmXresources` (dwm), `mkDunstColors` (dunst),
`mkStarshipPalette` (starship), `mkXsecurelockEnv` (xsecurelock), `mkBashPalette`
(shell-core). See the App consumption table below.

`pkgs.fontPackages` (overlay) maps a fontconfig family string → the nixpkgs
package that provides it (defined as `fontPackagesFor` in `lib/theme/fonts.nix`,
applied to the package set in the overlay); an app module installs the package for
the font it resolves, so a registered "official" family is provisioned on every
host. Ad-hoc (unregistered) families install nothing — the user provisions those.

**Icon glyphs.** The kitty module additionally installs the theme `glyphs` role
font (`Symbols Nerd Font` → `nerd-fonts.symbols-only`) on **every** host,
regardless of the primary font, and `home/apps/kitty/config/kitty.conf` pins the
Nerd Font private-use ranges to `Symbols Nerd Font Mono` via `symbol_map` (ranges
track Nerd Fonts v3.4.0, per the kitty FAQ). This guarantees Neovim/CLI devicons
render even when the primary font is not a Nerd Font — no per-host font juggling
required.

## Host selection

```nix
hostSettings = {
  theme = "purple-city"; # dir name in themes/
};

# In the consumer's owning app host files:
my.apps.nvim.scheme = "tokyonight-night"; # subset of associatedSchemes.nvim
my.apps.rofi.font = { family = "ibmplex"; size = "lg"; };
my.apps.kitty.font = { family = "IBM Plex Mono"; size = 18; };
```

Absent `hostSettings.theme`, app modules fall back to `"everforest"`. Each
`my.apps.<app>.font` is merged over the app's own default and the theme role
(highest precedence) and resolved through `fontOf`; omit it to take the theme
default. The app-scoped placement extends ADR-0018's ownership rule from emitters
to app-owned values; nix-secrets ADR-0019 records the private consumer decision.

## App consumption

Each app owns its emitter(s) in `home/apps/<app>/theme.nix` and wires them in its
`default.nix`, resolving colors/fonts through the `pkgs.themeLib` primitives.

| App | Emitter(s) in `theme.nix` | Wired in `default.nix` as |
| --- | --- | --- |
| rofi | `mkRofiColors` + `mkRofiFont` | `active-theme.rasi` (+ `@import layout.rasi`) and `programs.rofi.font` |
| kitty | `mkKittyTheme` + `mkKittyFont` (colors **and** font) | `current-theme.conf` (kitty.conf `include`s it) |
| dwm | `mkDwmXresources` (font not wired — follow-up) | appended to `Xresources`; read by `loadxrdb` (Mod+F5 reload) |
| dunst | `mkDunstColors` | `dunst/dunstrc.d/zzz-theme.conf` drop-in |
| starship | `mkStarshipPalette` | `[palettes.theme]` appended to `starship.toml` |
| xsecurelock | `mkXsecurelockEnv` | color lines appended to `env.conf` |
| shell-core | `mkBashPalette` | `bash/theme-palette.bash` (`__UI_SGR`) |
| nvim | — (name-ref only, native plugin) | reads `config.my.apps.nvim.scheme` (co-located; consumer repo) |

Note: the kitty/rofi fonts are wired from the SoT `typography` today (via
`fontOf` + per-app defaults + `my.apps.<app>.font`); dwm's font is still a
follow-up. The named font is provisioned through `pkgs.fontPackages`.
