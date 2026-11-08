{ config, ... }:
{
  programs.ghostty = {
    enable = true;
    # ghostty starts tmux, not the shell; its zsh integration would also fight
    # the vi-mode cursor set in home/zsh
    enableZshIntegration = false;
    settings = {
      # disable client-side decorations — niri handles window borders
      window-decoration = false;

      # colours come from Noctalia's built-in ghostty template (below): it
      # writes ~/.config/ghostty/themes/noctalia on every theme change
      # (dark ↔ light with Mod+Shift+T) and reloads open terminals.
      # "?" = optional, so a missing file (fresh install) is not an error
      config-file = "?${config.xdg.configHome}/ghostty/themes/noctalia";
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

  # Noctalia can't add the theme line itself (this config is read-only from
  # the Nix store), so it's set above; Noctalia only writes the theme file
  programs.noctalia.settings.theme.templates = {
    enable_builtin_templates = true;
    builtin_ids = [ "ghostty" ];
  };
}
