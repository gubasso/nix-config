# Everforest — Usage

## Apply to a host

In the consumer repo (`nix-secrets`):

```nix
hostSettings = {
  theme = "everforest";                    # also the default if theme is unset
  appSchemes = { nvim = "everforest"; };
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

- **nvim:** `everforest`

Pick one via `hostSettings.appSchemes.<app>`; validated against this list.
kitty/rofi/dwm use the emitted palette, so they have no sibling entry.

## Anti-patterns

- Don't hand-edit generated files (`current-theme.conf`, `active-theme.rasi`, the
  dwm Xresources color block) — edit `theme.nix`.
- Don't raise contrast/saturation ad hoc; that breaks Everforest's character.
