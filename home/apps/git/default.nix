# Public git enablement, allowed signers, and convenience aliases.
{ pkgs, ... }:

{
  programs.git.enable = true;
  xdg.configFile."git/allowed_signers".source = ./allowed_signers;

  # git-cliff: changelog generator. ungit: web-based git GUI (was an `npm -g`
  # install under a ~/.local prefix; now from nixpkgs like the rest).
  home.packages = [
    pkgs.git-cliff
    pkgs.ungit
  ];
  programs.bash.shellAliases = {
    gc = "git commit";
    gcm = "git commit -m";
    ga = "git add -A";
    gac = "git add -A && git commit";
    gacm = "git add -A && git commit -m";
    gp = "git push";
    gpu = "git push --set-upstream origin";
    gpl = "git pull";
    gplu = "git pull --set-upstream origin";
    gup = "git add -A && git commit -m \"up\" && git push";
    gs = "git switch";
    gb = "git --no-pager branch";
    gbd = "git branch -d";
    gbn = "git switch -c";
  };
}
