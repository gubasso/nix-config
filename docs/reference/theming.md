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
  semantic  = {                     # role -> slot (or another role) name
    bg surface overlay muted fg emphasis border
    accent error warn success info;
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

`name` must equal the directory name. Every `semantic` value must resolve to a
palette slot (directly, or via another semantic role).

## base16 semantic-slot standard

| Slots | Meaning |
| --- | --- |
| base00 | background |
| base01 | surface (lighter bg) |
| base02 | overlay / border / selection |
| base03 | muted / comments |
| base04 | dim foreground |
| base05 | default foreground |
| base06–07 | bright foreground |
| base08 | red — **error** |
| base09 | orange — **warn** |
| base0A | yellow |
| base0B | green — **success** |
| base0C | cyan — **info** |
| base0D | blue |
| base0E | magenta |
| base0F | brown |

Terminal ANSI `color0..15` derive from a fixed base16 slot order (see
`lib/theme/emitters.nix:ansiSlots`); `accent`/`success`/`info` etc. are chosen
per theme via the semantic layer, so a green theme points `accent` at `base0B`
and a purple one at `base0E`.

## `lib/theme` — resolver + emitters

Exposed as `pkgs.themeLib` (overlay, for app modules) and `flake.lib.theme`.

Module layout: color resolve/emitters live in `default.nix` + `emitters.nix`; the
whole **font subsystem** (`fontOf`, `mkKittyFont`, `mkRofiFont`, and the
`fontPackagesFor` provisioning map) lives in `lib/theme/fonts.nix` and is
re-exported here, so the `themeLib`/`fontPackages` names below are unchanged. The
default font tokens are shared in `themes/_shared/typography.nix` (imported by
each theme's `typography`).

- `resolve name` → the theme attrset (throws on unknown name).
- `colorOf theme role` → hex for a semantic role or raw slot.
- `fontOf theme { role?; family?; size? }` → resolved `{ family = "<string>";
  size = <int|null>; }`. `family`/`size` may be registry/scale tokens or literal
  values (a literal family string is the escape hatch); an explicit spec value
  overrides the role default. Callers layer precedence by merging attrs before the
  call: `fontOf theme (roleDefault // appDefault // hostOverride)`.
- `mkRofiColors theme` → rofi `* { … }` color block (canonical vars: `@bg
  @surface @overlay @muted @fg @accent @border @error @warn @success @info`).
- `mkRofiFont font` → rofi/pango `"Family Size"` string (for `programs.rofi.font`).
- `mkKittyTheme theme font` → kitty `current-theme.conf` body (colors **and**
  `font_family`/`font_size`).
- `mkDwmXresources theme` → Xresources block (`dwm.{norm,sel}{bg,fg,border}color`
  + `color0..15`).
- `assertAppScheme theme app scheme` → validates a host pick is in the theme's
  `associatedSchemes.<app>`; returns the scheme or throws.

`pkgs.fontPackages` (overlay) maps a fontconfig family string → the nixpkgs
package that provides it (defined as `fontPackagesFor` in `lib/theme/fonts.nix`,
applied to the package set in the overlay); an app module installs the package for
the font it resolves, so a registered "official" family is provisioned on every
host. Ad-hoc (unregistered) families install nothing — the user provisions those.

## Host selection

```nix
hostSettings = {
  theme = "purple-city";                       # dir name in themes/
  appSchemes = { nvim = "tokyonight-night"; };  # ⊆ associatedSchemes.<app>
  appFonts = {                                  # per-app font override (optional)
    rofi  = { family = "ibmplex"; size = "lg"; };  # tokens …
    kitty = { family = "IBM Plex Mono"; size = 18; };  # … or literals
  };
};
```

Absent `hostSettings.theme`, app modules fall back to `"everforest"`. Each
`appFonts.<app>` is merged over the app's own default and the theme role (highest
precedence) and resolved through `fontOf`; omit it to take the theme default.

## App consumption

| App | Colors | Font | File |
| --- | --- | --- | --- |
| rofi | `mkRofiColors` + `@import layout.rasi` → `active-theme.rasi` | `fontOf` → `mkRofiFont` → `programs.rofi.font` | `home/apps/rofi/default.nix` |
| kitty | `mkKittyTheme` overlaid as `current-theme.conf` (kitty.conf `include`s it) | `fontOf` (mono role) folded into the same `current-theme.conf` | `home/apps/kitty/default.nix` |
| dwm | `mkDwmXresources` appended to `Xresources`; read by `loadxrdb` (Mod+F5 reload) | not wired (follow-up) | `home/apps/dwm/default.nix` |
| nvim | reads `hostSettings.appSchemes.nvim` (name-ref; native plugin) | n/a | consumer repo |

Note: the kitty/rofi fonts are wired from the SoT `typography` today (via
`fontOf` + per-app defaults + `hostSettings.appFonts`); dwm's font is still a
follow-up. The named font is provisioned through `pkgs.fontPackages`.
