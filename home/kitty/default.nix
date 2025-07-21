{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";
    };
  };
}
