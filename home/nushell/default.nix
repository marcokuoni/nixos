{ config, ... }:
{
  programs = {
    nushell = {
      enable = true;

      settings = {
        show_banner = false;
        # vim keybindings on the command line: Esc = normal mode, i/a = insert mode
        edit_mode = "vi";
        # the cursor shows the mode: line = insert, block = normal
        cursor_shape = {
          vi_insert = "line";
          vi_normal = "block";
        };
        # history-based suggestions (like zsh-autosuggestions) are on by default,
        # accept them with → or Ctrl+F
      };

      # zsh used to pick these up from home.sessionVariables; nushell doesn't
      environmentVariables = {
        inherit (config.home.sessionVariables) EDITOR VISUAL;
      };

      shellAliases = {
        # git shortcuts (own ones + the most used oh-my-zsh git plugin ones)
        g = "git";
        ga = "git add";
        gaa = "git add --all";
        gb = "git branch";
        gc = "git commit";
        gcb = "git checkout -b";
        gco = "git checkout";
        gd = "git diff";
        gds = "git diff --staged";
        gf = "git fetch";
        gl = "git pull";
        glg = "git log --graph --abbrev-commit --date=relative";
        glo = "git log --oneline --decorate";
        gp = "git push";
        gpf = "git push --force-with-lease --force-if-includes";
        grb = "git rebase";
        gsh = "git show";
        gst = "git status";
        gsw = "git switch";

        # safer mv — prompt before overwriting (core-mv is defined in extraConfig)
        mv = "core-mv --interactive";
      };

      extraConfig = ''
        # keep the built-in mv reachable, so the mv alias doesn't call itself
        alias core-mv = mv

        # extract zip into folder with same name as the archive (bsdtar from libarchive)
        def unzip_folder [archive: path] {
          let name = ($archive | path parse | get stem)
          mkdir $name
          ^bsdtar -xf $archive -C $name
        }
      '';
    };

    # prompt with directory + git branch/status (replaces the agnoster theme)
    starship = {
      enable = true;
      enableNushellIntegration = true;
    };

    # nix develop / nix shell / nix-shell drop into nushell instead of bash
    # (leaves explicit --command / --run alone)
    nix-your-shell = {
      enable = true;
      enableNushellIntegration = true;
    };

    # completions for external commands (git, nix, docker, …) with descriptions
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
