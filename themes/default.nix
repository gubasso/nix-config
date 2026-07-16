# Theme registry — the catalogue of canonical, host-agnostic themes. Each entry
# is a pure Nix attrset (see docs/reference/theming.md for the schema). Add a
# theme by creating ./<name>/theme.nix and one line here; see
# docs/guides/authoring-a-theme.md.
{
  purple-city = import ./purple-city/theme.nix;
  everforest = import ./everforest/theme.nix;
}
