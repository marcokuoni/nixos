{pkgs, ...}: {
  # beamer-mirror: turns on HDMI output and starts mirroring eDP-1 to it
  # usage: run manually or bind to a key in niri
  home.packages = [
    (pkgs.writeShellScriptBin "beamer-mirror" ''
      #!/usr/bin/env bash
      wlr-randr --output HDMI-A-1 --on
      wl-mirror eDP-1 &
      sleep 0.5
    '')
  ];
}
