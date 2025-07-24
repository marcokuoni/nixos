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
      font.name = "Ubuntu Nerd Font";

    };
  };
}
