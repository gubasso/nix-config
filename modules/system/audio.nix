_:

{
  # Disable the standalone PulseAudio service; PipeWire provides pulse compat.
  services.pulseaudio.enable = false;

  # Realtime priorities for the audio stack.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    pulse.enable = true;

    wireplumber.enable = true;
  };

  # NOTE: dock-audio workaround is session-coupled -> round 4. Not here.
}
