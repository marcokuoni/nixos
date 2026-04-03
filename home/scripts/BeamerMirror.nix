{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "beamer-mirror" ''
      #!/usr/bin/env bash

      wlr-randr --output HDMI-A-1 --on
      wl-mirror eDP-1 &
      sleep 0.5
    '')
  ];
}
