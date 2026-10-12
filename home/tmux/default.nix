{ config, pkgs, ... }:
{
  home.packages = [ pkgs.wl-clipboard ]; # wl-copy / wl-paste

  programs.tmux = {
    enable = true;
    shell = "${config.programs.zsh.package}/bin/zsh";
    keyMode = "vi";
    escapeTime = 0; # otherwise Esc in zsh's vi mode is delayed
    historyLimit = 50000;
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g destroy-unattached on
      set -g status off # no status bar at the bottom

      # Esc Esc (while zsh is in front) -> copy mode: scroll and search the
      # history in place. The first Esc still reaches zsh (vi normal mode).
      bind -n Escape if -F '#{==:#{pane_current_command},zsh}' {
        send-keys Escape
        switch-client -T shellesc
      } {
        send-keys Escape
      }
      bind -T shellesc Escape copy-mode

      # tmux's own copy mode stays on prefix + [
      set -s copy-command 'wl-copy'
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi V send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel
      bind -T copy-mode-vi i send -X cancel
      bind -T copy-mode-vi Escape send -X clear-selection
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel
    '';
  };
}
