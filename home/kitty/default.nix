{
  inputs,
  pkgs,
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
