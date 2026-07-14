# eza package and ls-style aliases.
_:

{
  programs.eza.enable = true;
  programs.bash.shellAliases = {
    ls = "eza";
    ll = "eza -la";
    tree = "eza --tree --all --git-ignore --ignore-glob \".git\"";
  };
}
