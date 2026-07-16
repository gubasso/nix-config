# Purple City — Motion

The environment is a static X11 tiling setup (dwm); motion is minimal by design.

## Stance

- **No decorative animation.** Window management is instant; transitions are for
  legibility, not flourish.
- **Compositor (picom):** subtle fade on window open/close is acceptable; avoid
  long durations or heavy blur that fight the dark, high-contrast look.
- **No flashing.** Nothing in the theme should strobe or pulse (accessibility and
  focus).
- **Reduced-motion friendly.** Because motion is near-zero already, the theme is
  inherently comfortable for motion-sensitive users.

This is a note-level concern: the theme defines colors and type, not animation
curves. Compositor timing lives in the picom config, not the theme SoT.
