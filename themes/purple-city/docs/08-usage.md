# Purple City — Usage

How this theme reaches each app, and how to apply it.

## Apply to a host

In the consumer repo (`nix-secrets`), set:

```nix
hostSettings = {
  theme = "purple-city";
  appSchemes = { nvim = "catppuccin"; };  # a sibling from associatedSchemes
};
```

Then `home-manager switch` (rofi + kitty reload; dwm re-reads Xresources on
start or Mod+F5).

## What derives from the SoT

| App | How | Result |
| --- | --- | --- |
| rofi | `mkRofiColors` + shared `layout.rasi` | launcher colors |
| kitty | `mkKittyTheme` → `current-theme.conf` | terminal palette + ANSI |
| dwm | `mkDwmXresources` → Xresources | border/select colors + `color0..15` |

## Sibling schemes (name-reference)

`associatedSchemes` offers, for editors with their own polished themes:

- **nvim:** `catppuccin`

A host picks one via `hostSettings.appSchemes.<app>`; the app loads it natively.
The pick is validated against this list (`assertAppScheme`). kitty/rofi/dwm are
driven by the emitted palette, so they have no sibling entry.

## Anti-patterns

- Don't hand-edit `current-theme.conf` / `active-theme.rasi` / the dwm Xresources
  color block — they are generated; edit `theme.nix`.
- Don't add a sixth rofi `.rasi` per theme — the layout is shared; only the
  palette varies.
- Don't point `appSchemes.nvim` at a scheme not in `associatedSchemes.nvim`.
