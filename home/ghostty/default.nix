{ config, ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # disable client-side decorations — niri handles window borders
      window-decoration = false;
      # every window starts in tmux (absolute path, independent of PATH)
      command = "${config.programs.tmux.package}/bin/tmux new-session";

      # Swiss layout friendly font size keys
      # Ctrl+Less (<) to increase, Ctrl+Minus (-) to decrease
      keybind = [
        "ctrl+<=increase_font_size:1"
        "ctrl+-=decrease_font_size:1"
        "ctrl+0=reset_font_size"
      ];
    };
  };
}
