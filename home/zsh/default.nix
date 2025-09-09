{
  config,
  pkgs,
  ...
}: let
  shellAliases = {
    g = "git";
    ga = "git add";
    gc = "git commit";
    gd = "git diff";
    gds = "git diff --staged";
    gf = "git fetch";
    glg = "git log --graph --abbrev-commit --date=relative";
    gp = "git push";
    gpf = "git push --force-with-lease --force-if-includes";
    gsh = "git show";
    gst = "git status";

    nix-shell = "nix-shell --command zsh";

    mv = "mv -i";
  };
in {
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      inherit shellAliases;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "vi-mode"
        ];
        theme = "agnoster";
      };
    };

    bash = {
      inherit shellAliases;
    };
  };

  home.packages = with pkgs; [
    oh-my-zsh
  ];
}
