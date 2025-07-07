{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "refresh-waybar" ''
#!/usr/bin/env bash

pkill waybar
waybar &
    '')
  ];
}

