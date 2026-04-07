{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";
    prefix = "C-Space"; # statt default C-b

    extraConfig = ''
      # Fenster mit aktuellem Pfad aufteilen
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind p paste-buffer

      bind v copy-mode
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi Escape send -X cancel
      bind -T copy-mode-vi i send -X cancel
      bind -T copy-mode-vi 0 send -X start-of-line
      bind -T copy-mode-vi $ send -X end-of-line
      bind -T copy-mode-vi w send -X next-word
      bind -T copy-mode-vi b send -X previous-word
      bind -T copy-mode-vi e send -X next-word-end
      bind -T copy-mode-vi / send -X search-forward
      bind -T copy-mode-vi n send -X search-again
      bind -T copy-mode-vi N send -X search-reverse
      bind -T copy-mode-vi G send -X history-bottom
      bind -T copy-mode-vi g send -X history-top
      bind-key -T copy-mode-vi y send -X copy-selection

      # Status bar
      set -g status-style bg=default
    '';
  };
}
