# Purple City — Principles

- **One accent, used sparingly.** Magenta marks *what is active or selected*.
  Don't spread it across decoration; its power is scarcity.
- **Backgrounds recede, foreground leads.** Near-black base, soft off-white text.
  Chrome (borders, surfaces) sits between, never competing with content.
- **Semantic colors keep their jobs.** Red = error, amber = warning, green =
  success, blue/cyan = info. Never repurpose them for aesthetics.
- **Contrast is a feature.** Body text targets WCAG AA or better against the
  background (see `05-accessibility.md`).
- **Calm motion.** No flashing or high-saturation churn; the theme is for
  concentration.

## Do

- Use `accent` for selection, active borders, prompts.
- Use `surface`/`overlay` for layered chrome (menus, input bars).

## Don't

- Don't tint large background regions with the accent.
- Don't introduce hues outside the palette; extend the palette instead.
