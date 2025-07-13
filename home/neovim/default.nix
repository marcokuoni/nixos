{ pkgs, ... }:

{
# https://github.com/bkp5190/Home-Manager-Configs/blob/main/home.nix

  programs = {
    nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      luaLoader.enable = true;
    };
  };
}
