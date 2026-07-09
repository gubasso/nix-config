{ inputs }:
final: prev: {
  dwm = import ../pkgs/dwm { pkgs = prev; inherit inputs; };
  dwm-session = import ../pkgs/dwm-session { pkgs = prev; };
}
