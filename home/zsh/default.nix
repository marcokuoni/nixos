{pkgs, ...}: let
  shellAliases = {
    # git shortcuts
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

    # always open nix-shell with zsh instead of bash
    nix-shell = "nix-shell --command zsh";

    # safer mv — prompt before overwriting
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
          "vi-mode" # vim keybindings in the shell, consistent with nvim/tmux
        ];
        theme = "agnoster";
      };

      # initContent = ''
      #   # Auto-attach to tmux on shell start.
      #   # $TMUX check prevents nesting when opening new panes inside tmux.
      #   if [ -z "$TMUX" ]; then
      #     tmux attach-session -t main || tmux new-session -s main
      #   fi
      # '';
    };

    # share the same aliases in bash (for scripts / fallback shells)
    bash.shellAliases = shellAliases;
  };

  home.packages = with pkgs; [
    oh-my-zsh
  ];
}
