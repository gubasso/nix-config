# yazi terminal file manager (backs yazi.nvim) + optional CLI tools it uses for
# rich previews. fd/ripgrep/fzf/zoxide have their own home/apps modules and are
# intentionally omitted here to avoid duplicate home.packages entries.
{ pkgs, ... }:

{
  home.packages = [
    pkgs.yazi
    pkgs.ffmpeg # video thumbnails
    pkgs.p7zip # archive preview/extraction
    pkgs.jq # JSON preview
    pkgs.poppler-utils # PDF preview (pdftoppm)
    pkgs.imagemagick # image previews/ops
    pkgs.resvg # SVG previews
  ];
}
