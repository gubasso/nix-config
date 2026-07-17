# Guide: authoring a theme

How to add a new theme to the catalogue. Schema details are in
[../reference/theming.md](../reference/theming.md).

## 1. Create the theme directory

```
themes/<name>/
  theme.nix        # the SoT
  docs/            # brand-book (copy the structure of themes/purple-city/docs)
    01-identity.md 02-principles.md 03-color.md 04-typography.md
    05-accessibility.md 06-iconography.md 07-motion.md 08-usage.md
```

`<name>` is the identifier used by `hostSettings.theme` and must equal
`meta.name`.

## 2. Fill `theme.nix`

1. **Palette** — set `base00`…`base0F`. Follow the base16 slot standard
   (`docs/reference/theming.md`): dark → light backgrounds/foregrounds in
   `base00`–`base07`, accent hues in `base08`–`base0F`. Reuse an established
   base16 scheme's values if you're porting one.
2. **Semantic** — map each role to a slot. Point `accent` at the theme's
   signature hue (e.g. `base0B` for a green theme, `base0E` for a purple one).
3. **Typography** — a `families` registry (token → fontconfig family), a `sizes`
   scale, and `roles` (`mono`/`ui`/`glyphs`) binding family+size tokens. Any
   family an app resolves must have a matching entry in `pkgs.fontPackages`
   (`overlays/default.nix`) to be provisioned automatically.
4. **associatedSchemes** — list the upstream scheme *names* each app can load
   natively (nvim colorschemes, kitty built-in themes). Name references only.

## 3. Register it

Add one line to `themes/default.nix`:

```nix
<name> = import ./<name>/theme.nix;
```

## 4. Write the brand-book

Fill the eight docs. The important one for correctness is `03-color.md`
(palette + semantic mapping) and `05-accessibility.md` — verify the key pairs
meet **WCAG 2.x AA**: 4.5:1 for body text (fg on bg), 3:1 for UI/large text and
borders. Use any contrast checker; record the ratios in the table.

## 5. Verify

```bash
nix eval --raw .#lib.theme.registry.<name>.meta.label
# emitters are app-owned (ADR-0018); check the theme resolves + a color emits
nix eval --impure --raw --expr \
  'let f = builtins.getFlake (toString ./.); t = f.lib.theme; in t.colorOf (t.resolve "<name>") "accent"'
just lint
nix flake check
```

To see it live, set a host's `hostSettings.theme = "<name>"` in the consumer
repo (`nix-secrets`) and `home-manager switch` (rofi/kitty reload; dwm re-reads
Xresources on start or Mod+F5).
