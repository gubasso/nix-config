{ pkgs }:

# dwm built from the public fork (github.com/gubasso/dwm @ rice). The source is
# fetched HERE, next to the derivation, not as a loose top-level flake.nix input,
# so this component's setup stays self-contained. Bump rev + hash to update. The
# fork is the single source of truth for patches and config (its config.def.h);
# everything else (build/install) inherits from nixpkgs.
pkgs.dwm.overrideAttrs (_: {
  src = pkgs.fetchFromGitHub {
    owner = "gubasso";
    repo = "dwm";
    rev = "af6f53cb709af67be045731012a10baf992c5eb7";
    hash = "sha256-YzpXMa0c1JQMzR7QE/zpNpe0A8ycQJSvhEib3XreuF4=";
  };
})
