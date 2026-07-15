# Claude Code CLI (Anthropic's agentic coding tool).
# Prebuilt binary wrapped by nixpkgs with its auto-updater disabled -- the store
# is read-only, so updates come through nix, not the CLI. Unfree license; home
# hosts already set config.allowUnfree (lib/mk-home-host.nix).
{ pkgs, ... }:

{
  home.packages = [ pkgs.claude-code ];
}
