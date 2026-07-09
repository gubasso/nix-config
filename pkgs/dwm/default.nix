{ pkgs, inputs }:

# dwm built from the personal fork (github.com/gubasso/dwm @ rice), pinned via the
# `dwm-fork` flake input. The fork is the single source of truth for patches and
# config (its config.def.h). Everything else (build/install) inherits from nixpkgs.
pkgs.dwm.overrideAttrs (_: {
  src = inputs.dwm-fork;
})
