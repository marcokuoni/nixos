{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      window-decoration = false; # gut für niri mit prefer-no-csd
    };
  };
}
