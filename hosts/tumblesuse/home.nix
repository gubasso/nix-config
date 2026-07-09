{ lib, ... }:

{
  home.packages = [ ];

  home.sessionVariables = {
    LOCALE_ARCHIVE = lib.mkDefault "/usr/lib/locale/locale-archive";
  };
}
