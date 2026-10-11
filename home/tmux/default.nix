{ pkgs, ... }:
{
  home.packages = [ pkgs.wl-clipboard ]; # wl-copy / wl-paste

  programs.tmux = {
    enable = true;
    shell = "${pkgs.nushell}/bin/nu";
    keyMode = "vi";
    escapeTime = 0; # otherwise Esc in nushell's vi mode is delayed
    historyLimit = 50000;
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g destroy-unattached on
      set -g status off # no status bar at the bottom

      # Esc Esc (while nushell is in front) -> scrollback in nvim.
      # The first Esc still reaches nushell (vi normal mode).
      bind -n Escape if -F '#{==:#{pane_current_command},nu}' {
        send-keys Escape
        switch-client -T nuesc
      } {
        send-keys Escape
      }
      bind -T nuesc Escape copy-mode

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
