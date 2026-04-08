{pkgs, ...}: {
  programs.tmux = {
    enable = true;

    # use zsh as the default shell inside tmux panes
    shell = "${pkgs.zsh}/bin/zsh";
    # also set default-command so new panes inherit zsh correctly
    extraConfig =
      ''
        set -g default-command "${pkgs.zsh}/bin/zsh"
      ''
      + ''
        # ── Splits ─────────────────────────────────────────────────────────────
        # | and - are more intuitive than % and "
        # -c inherits the current pane's working directory
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # ── Pane navigation ────────────────────────────────────────────────────
        # vim-style hjkl instead of arrow keys
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # ── Copy mode (vim visual mode feel) ───────────────────────────────────
        # prefix + v enters copy mode (like entering normal mode in vim)
        bind v copy-mode

        # v / V / C-v mirror vim's visual / visual-line / visual-block
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi V send -X select-line
        bind -T copy-mode-vi C-v  send -X rectangle-toggle

        # exit copy mode with Escape or i (like leaving visual mode)
        bind -T copy-mode-vi Escape send -X cancel
        bind -T copy-mode-vi i      send -X cancel

        # line motion — vim style
        bind -T copy-mode-vi 0 send -X start-of-line
        bind -T copy-mode-vi $ send -X end-of-line

        # word motion
        bind -T copy-mode-vi w send -X next-word
        bind -T copy-mode-vi b send -X previous-word
        bind -T copy-mode-vi e send -X next-word-end

        # search (like / and n/N in vim)
        bind -T copy-mode-vi /  send -X search-forward
        bind -T copy-mode-vi n  send -X search-again
        bind -T copy-mode-vi N  send -X search-reverse

        # jump to top/bottom of scrollback
        bind -T copy-mode-vi G send -X history-bottom
        bind -T copy-mode-vi g send -X history-top

        # y copies selection, p pastes — mirrors vim yank/put
        bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"
        bind p paste-buffer

        # ── Status bar ─────────────────────────────────────────────────────────
        # transparent background — inherits terminal/noctalia theme colors
        set -g status-style bg=default
      '';

    terminal = "screen-256color";
    historyLimit = 10000;
    mouse = true;

    # vi keybindings in copy mode — j/k scroll, v selects etc.
    keyMode = "vi";

    # C-Space is less conflicting than C-b (readline) or C-a (screen)
    prefix = "C-Space";
  };
}
