{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";
    prefix = "C-a"; # statt default C-b

    extraConfig = ''
      # Fenster mit aktuellem Pfad aufteilen
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Status bar
      set -g status-style bg=default
    '';
  };
}
