{ config, pkgs, ... }:

{
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        position = "left";
      };
    };
  };
}
