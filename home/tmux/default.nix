{ pkgs, ... }:
let
  # write the pane's whole scrollback to a file and open it in nvim (fullscreen popup)
  scrollbackInNvim = pkgs.writeShellScript "tmux-scrollback-nvim" ''
    pane="$1"
    client="$2"
    file="''${XDG_RUNTIME_DIR:-/tmp}/tmux-scrollback-''${pane#%}.txt"
    tmux capture-pane -p -J -S - -E - -t "$pane" > "$file"
    tmux display-popup -c "$client" -E -w 100% -h 100% \
      "nvim -R -c 'normal! G' -c 'nnoremap q <cmd>qa!<cr>' $file"
  '';
in
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

      # Esc Esc (while nushell is in front) -> scrollback in nvim.
      # The first Esc still reaches nushell (vi normal mode).
      bind -n Escape if -F '#{==:#{pane_current_command},nu}' {
        send-keys Escape
        switch-client -T nuesc
      } {
        send-keys Escape
      }
      bind -T nuesc Escape run-shell -b '${scrollbackInNvim} "#{pane_id}" "#{client_name}"'

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
