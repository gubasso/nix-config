# shellcheck shell=bash
alias nrs='sudo nixos-rebuild switch --flake "$HOME/.dotfiles/nix#lyra"'
alias nrb='sudo nixos-rebuild boot --flake "$HOME/.dotfiles/nix#lyra"'
alias nrt='sudo nixos-rebuild test --flake "$HOME/.dotfiles/nix#lyra"'
alias nfu='nix flake update "$HOME/.dotfiles/nix"'
