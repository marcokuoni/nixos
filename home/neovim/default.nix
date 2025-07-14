{ inputs, pkgs, nixvim, ... }:
{
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      nixpkgs.useGlobalPackages = true;

      viAlias = true;
      vimAlias = true;
    };

    home.packages = with pkgs; [
      neovim
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
    };
}
