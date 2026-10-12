# Noctalia v5 — bar, launcher, notifications, lock screen, wallpaper.
# Settings are written to ~/.config/noctalia/config.toml.
# Docs: https://docs.noctalia.dev/noctalia/configuration/
# Changes made in the Settings GUI land in ~/.local/state/noctalia/settings.toml
# and win over this file — delete that file to go back to what is declared here.
{
  programs.noctalia = {
    enable = true;

    settings = {
      shell = {
        corner_radius_scale = 0.2; # mostly square corners
      };

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Ayu";
      };

      wallpaper.automation = {
        enabled = true;
        interval_seconds = 600; # new random wallpaper every 10 minutes
        order = "random";
      };

      # weather, night light and auto theme use this
      location.address = "Glarus, Switzerland";

      battery.warning_threshold = 30;

      # vertical bar on the left, suits niri's column layout
      bar.main = {
        position = "left";
        capsule = false;
        start = [
          "control-center"
          "network" # Wi-Fi / wired, with the VPN state built in
          "bluetooth"
        ];
        center = [ "workspaces" ];
        end = [
          "privacy" # mic / camera / screen-share indicator
          "tray" # nextcloud etc.
          "battery"
          "clock"
        ];
      };

      widget = {
        control-center.glyph = "home";
        network.vpn_status = "both";
        workspaces = {
          show_labels = false; # dots only, no workspace numbers
          hide_when_empty = false;
        };
        privacy.hide_inactive = true;
        # nm-applet keeps running (it asks for VPN passwords, which Noctalia's
        # network widget can't), but the network widget above shows Wi-Fi + VPN
        tray.hidden = [ "nm-applet" ];
        battery.show_label = false; # percentage only in the tooltip
        clock = {
          format = "{:%d · %H:%M:%S}";
          vertical_format = "{:%d\n──\n%H\n%M\n%S}";
        };
      };

    };
  };

  # terminal apps started from the launcher open in ghostty
  home.sessionVariables.TERMINAL = "ghostty";
}
