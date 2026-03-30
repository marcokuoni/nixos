{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    # kein extra Flake nötig, ist in nixpkgs
    settings = {
      font-size = 11;
      window-decoration = false; # gut für niri mit prefer-no-csd

    };
  };
}
