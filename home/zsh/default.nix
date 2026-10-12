# zsh with the look and feel nushell had: starship prompt, vi mode with the
# cursor showing the mode, grey suggestions from history, completions with
# descriptions (carapace) and highlighting while typing.
{ pkgs, ... }:
let
  wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
in
{
  programs = {
    zsh = {
      enable = true;

      # vi keybindings on the command line: Esc = normal mode, i/a = insert mode
      defaultKeymap = "viins";

      # grey suggestion from history while typing; accept with → or Ctrl+F
      autosuggestion.enable = true;
      # commands turn green (found) or red (unknown) while typing
      syntaxHighlighting.enable = true;

      history = {
        size = 50000;
        save = 50000;
        share = true; # all open shells see each other's history
        ignoreDups = true;
        ignoreSpace = true; # a command starting with a space isn't saved
      };

      # all oh-my-zsh git aliases (gst, gco, gcmsg, glol, …), without the rest
      # of oh-my-zsh; lib/git.zsh provides the helpers some of them use
      plugins = [
        {
          name = "oh-my-zsh-git";
          src = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
          file = "lib/git.zsh";
        }
        {
          name = "oh-my-zsh-git-plugin";
          src = "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git";
          file = "git.plugin.zsh";
        }
      ];

      # own aliases (loaded after the plugin, so these win)
      shellAliases = {
        g = "git";
        glg = "git log --graph --abbrev-commit --date=relative";
        gpf = "git push --force-with-lease --force-if-includes";
        gsh = "git show";
        # safer mv: ask before overwriting
        mv = "mv -i";
      };

      initContent = ''
        # Esc switches to normal mode immediately (default waits 0.4 s)
        KEYTIMEOUT=1

        # the cursor shows the mode: line = insert, block = normal
        _cursor_for_mode() {
          if [[ $KEYMAP == vicmd ]]; then print -n '\e[2 q'; else print -n '\e[6 q'; fi
        }
        autoload -Uz add-zle-hook-widget add-zsh-hook
        add-zle-hook-widget zle-keymap-select _cursor_for_mode
        add-zle-hook-widget zle-line-init _cursor_for_mode
        # back to the terminal's default cursor before each command,
        # so ssh, a remote vi, less etc. don't inherit the insert-mode line
        _cursor_reset() { print -n '\e[0 q'; }
        add-zsh-hook preexec _cursor_reset

        # p / P in normal mode paste the system clipboard (what nvim/tmux yanked)
        _vi_put_clipboard_after() { CUTBUFFER=$(${wl-paste} --no-newline 2>/dev/null) && zle vi-put-after; }
        _vi_put_clipboard_before() { CUTBUFFER=$(${wl-paste} --no-newline 2>/dev/null) && zle vi-put-before; }
        zle -N _vi_put_clipboard_after
        zle -N _vi_put_clipboard_before
        bindkey -M vicmd p _vi_put_clipboard_after
        bindkey -M vicmd P _vi_put_clipboard_before

        # insert mode keeps a few handy keys
        bindkey -M viins '^F' autosuggest-accept           # accept suggestion
        bindkey -M viins '^R' history-incremental-search-backward
        bindkey -M viins '^A' beginning-of-line
        bindkey -M viins '^E' end-of-line
        bindkey -M viins '^?' backward-delete-char         # Backspace past the insert point
        bindkey -M viins '^H' backward-delete-char
        bindkey -M viins '^W' backward-kill-word

        # ↑ / ↓ search the history for what's already typed
        autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        for keymap in viins vicmd; do
          bindkey -M $keymap '^[[A' up-line-or-beginning-search
          bindkey -M $keymap '^[OA' up-line-or-beginning-search
          bindkey -M $keymap '^[[B' down-line-or-beginning-search
          bindkey -M $keymap '^[OB' down-line-or-beginning-search
        done
        unset keymap

        # completion menu you can move through with the arrow keys / Tab
        zstyle ':completion:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # case-insensitive
        zstyle ':completion:*' format $'\e[2;37m%d\e[m'      # group headings

        # extract a zip into a folder named like the archive (bsdtar from libarchive)
        unzip_folder() {
          local name=''${1:t:r}
          mkdir -p -- "$name" && bsdtar -xf "$1" -C "$name"
        }
      '';
    };

    # prompt with directory + git branch/status
    starship.enable = true;

    # nix develop / nix shell / nix-shell drop into zsh instead of bash
    # (leaves explicit --command / --run alone)
    nix-your-shell.enable = true;

    # completions for external commands (git, nix, docker, …) with descriptions
    carapace.enable = true;
  };
}
