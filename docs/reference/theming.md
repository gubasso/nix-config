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
    mono   = { family; size; };
    ui     = { family; size; };
    glyphs = "<nerd-font family>";
    weights = { regular; medium; bold; };
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

- `resolve name` → the theme attrset (throws on unknown name).
- `colorOf theme role` → hex for a semantic role or raw slot.
- `mkRofiColors theme` → rofi `* { … }` color block (canonical vars: `@bg
  @surface @overlay @muted @fg @accent @border @error @warn @success @info`).
- `mkKittyTheme theme` → kitty `current-theme.conf` body.
- `mkDwmXresources theme` → Xresources block (`dwm.{norm,sel}{bg,fg,border}color`
  + `color0..15`).
- `assertAppScheme theme app scheme` → validates a host pick is in the theme's
  `associatedSchemes.<app>`; returns the scheme or throws.

## Host selection

```nix
hostSettings = {
  theme = "purple-city";                       # dir name in themes/
  appSchemes = { nvim = "tokyonight-night"; };  # ⊆ associatedSchemes.<app>
};
```

Absent `hostSettings.theme`, app modules fall back to `"everforest"`.

## App consumption

| App | Seam | File |
| --- | --- | --- |
| rofi | `mkRofiColors` + `@import layout.rasi` → generated `active-theme.rasi` | `home/apps/rofi/default.nix` |
| kitty | `mkKittyTheme` overlaid as `current-theme.conf` (kitty.conf `include`s it) | `home/apps/kitty/default.nix` |
| dwm | `mkDwmXresources` appended to `Xresources`; read by `loadxrdb` (Mod+F5 reload) | `home/apps/dwm/default.nix` |
| nvim | reads `hostSettings.appSchemes.nvim` (name-ref; native plugin) | consumer repo |

Note: fonts are defined in the SoT (`typography`) as the single source; wiring
kitty/rofi/dwm fonts from it is a follow-up — colors are wired today.
