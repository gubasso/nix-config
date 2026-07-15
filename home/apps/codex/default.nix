# OpenAI Codex CLI (the Rust rewrite; github.com/openai/codex). Apache-2.0.
{ pkgs, ... }:

{
  home.packages = [ pkgs.codex ];
}
