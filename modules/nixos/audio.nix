# Audio: PipeWire (with PulseAudio and ALSA compatibility).
{
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # extraConfig.pipewire."10-airplay" = {
    #   "context.modules" = [
    #     {
    #       name = "libpipewire-module-raop-discover";
    #       args = {
    #         "stream.props" = {
    #           "sess.latency.msec" = 2000;
    #         };
    #       };
    #     }
    #   ];
    # };
  };

  # realtime priority for low-latency audio
  security.rtkit.enable = true;
}
