# PipeWire and WirePlumber user drop-ins.
_:

{
  xdg.configFile = {
    "pipewire/pipewire.conf.d/10-clock-rates.conf".source = ./pipewire.conf.d/10-clock-rates.conf;
    "wireplumber/wireplumber.conf.d/50-bluez.conf".source = ./wireplumber.conf.d/50-bluez.conf;
    "wireplumber/wireplumber.conf.d/50-no-suspend.conf".source =
      ./wireplumber.conf.d/50-no-suspend.conf;
  };
}
