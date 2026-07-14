# bat package and cat-style aliases.
_:

{
  programs.bat.enable = true;
  programs.bash.shellAliases = {
    cat = "bat";
    batd = "bat --decorations=always";
  };
}
