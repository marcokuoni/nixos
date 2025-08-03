{
  inputs,
  pkgs,
  ...
}:
{
  programs = {
    # https://github.com/Alexays/Waybar/blob/master/resources/config.jsonc
    waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "bottom";
          modules-left = [
            "hyprland/workspaces"
            "wlr/taskbar"
          ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "idle_inhibitor"
            "pulseaudio"
            # "bluetooth"
            "network"
            "custom/openfortivpn"
            "custom/openvpn-int"
            "custom/openvpn-pub"
            "cpu"
            "memory"
            "temperature"
            "backlight"
            "keyboard-state"
            "battery"
            "clock"
          ];

          "custom/openvpn-int" = {
            exec = "vpn-int-status";
            return-type = "json";
            interval = 5;
            on-click = "vpn-int-toggle";
            format = "{}";
          };

          "custom/openvpn-pub" = {
            exec = "vpn-pub-status";
            return-type = "json";
            interval = 5;
            on-click = "vpn-pub-toggle";
            format = "{}";
          };

          "custom/openfortivpn" = {
            exec = "forti-status";
            return-type = "json";
            interval = 5;
            on-click = "forti-toggle";
            format = "{}";
          };

          "keyboard-state" = {
            numlock = false;
            capslock = true;
            format = "{name} {icon}";
            format-icons = {
              locked = "";
              unlocked = "";
            };
            # Refresh is done via capslock keybinding
          };

          "wlr/taskbar" = {
            format = "{icon}";
            tooltip = true;
            tooltip-format = "{title}";
            on-click = "activate";
            on-click-middle = "close";
            active-first = true;
          };

          "hyprland/window" = {
            separate-outputs = true;
          };

          "hyprland/workspaces" = {
            format = "{name} : {icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "urgent" = "";
              "active" = "";
              "default" = "";
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
          };

          clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%d.%m.%Y}";
          };

          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };

          memory = {
            format = "{}% ";
          };
          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = [
              ""
              ""
              ""
            ];
          };
          backlight = {
            format = "{percent}% {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
              ""
            ];
          };
          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-full = "{capacity}% {icon}";
            format-charging = "{capacity}% 󰂄";
            format-plugged = "{capacity}%  ";
            format-alt = "{time} {icon}";
            format-icons = [
              " "
              " "
              " "
              " "
              " "
            ];
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%)  ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠ ";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            on-click = "rofi-network-manager";
          };
          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = "󰆪 {icon} {format_source}";
            format-muted = "󰆪 {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = " ";
              hands-free = "󰋎 ";
              headset = "󰋎 ";
              phone = " ";
              portable = " ";
              car = " ";
              default = [
                ""
                " "
                " "
              ];
            };
            on-click = "pavucontrol";
          };
          # bluetooth = {
          #   controller = "controller1";
          #   format = " {status}";
          #   format-disabled = ""; # an empty format will hide the module
          #   format-connected = " {num_connections} connected";
          #   tooltip-format = "{controller_alias}\t{controller_address}";
          #   tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          #   tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          #   on-click = "rofi-bluetooth";
          # };
        };
      };
      style = ''
        * {
            /* `otf-font-awesome` is required to be installed for icons */
            font-family: FiraCode Nerd Font, Roboto, Helvetica, Arial, sans-serif;
            font-size: 13px;
        }

        window#waybar {
            background-color: rgba(43, 48, 59, 0.5);
            border-bottom: 3px solid rgba(100, 114, 125, 0.5);
            color: #ffffff;
            transition-property: background-color;
            transition-duration: .5s;
        }

        window#waybar.hidden {
            opacity: 0.2;
        }

        /*
        window#waybar.empty {
            background-color: transparent;
        }
        window#waybar.solo {
            background-color: #FFFFFF;
        }
        */

        window#waybar.termite {
            background-color: #3F3F3F;
        }

        window#waybar.chromium {
            background-color: #000000;
            border: none;
        }

        button {
            /* Use box-shadow instead of border so the text isn't offset */
            box-shadow: inset 0 -3px transparent;
            /* Avoid rounded borders under each button name */
            border: none;
            border-radius: 0;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        button:hover {
            background: inherit;
            box-shadow: inset 0 -3px #ffffff;
        }

        /* you can set a style on hover for any module like this */
        #pulseaudio:hover {
            background-color: #a37800;
        }

        #workspaces button {
            padding: 0 5px;
            background-color: transparent;
            color: #ffffff;
        }

        #workspaces button:hover {
            background: rgba(0, 0, 0, 0.2);
        }

        #workspaces button.focused {
            background-color: #64727D;
            box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.urgent {
            background-color: #eb4d4b;
        }

        #mode {
            background-color: #64727D;
            box-shadow: inset 0 -3px #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #wireplumber,
        #custom-media,
        #tray,
        #mode,
        #idle_inhibitor,
        #scratchpad,
        #power-profiles-daemon,
        #mpd {
            padding: 0 10px;
            color: #ffffff;
        }

        #window,
        #workspaces {
            margin: 0 4px;
        }

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left > widget:first-child > #workspaces {
            margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right > widget:last-child > #workspaces {
            margin-right: 0;
        }

        #clock {
            background-color: #64727D;
        }

        #battery {
            background-color: #ffffff;
            color: white;
        }

        #battery.charging, #battery.plugged {
            color: #ffffff;
            background-color: #26A65B;
        }

        @keyframes blink {
            to {
                background-color: #ffffff;
                color: #000000;
            }
        }

        /* Using steps() instead of linear as a timing function to limit cpu usage */
        #battery.critical:not(.charging) {
            background-color: #f53c3c;
            color: #ffffff;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: steps(12);
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #power-profiles-daemon {
            padding-right: 15px;
        }

        #power-profiles-daemon.performance {
            background-color: #f53c3c;
            color: #ffffff;
        }

        #power-profiles-daemon.balanced {
            background-color: #2980b9;
            color: #ffffff;
        }

        #power-profiles-daemon.power-saver {
            background-color: #2ecc71;
            color: white;
        }

        label:focus {
            background-color: #000000;
        }

        #cpu {
            background-color: #2ecc71;
            color: white;
        }

        #memory {
            background-color: #9b59b6;
        }

        #disk {
            background-color: #964B00;
        }

        #backlight {
            background-color: #90b1b1;
        }

        #network {
            background-color: #2980b9;
        }

        #network.disconnected {
            background-color: #f53c3c;
        }

        #pulseaudio {
            background-color: #a37800;
            color: white;
        }

        #pulseaudio.muted {
            background-color: #90b1b1;
            color: #2a5c45;
        }

        #wireplumber {
            background-color: #fff0f5;
            color: white;
        }

        #wireplumber.muted {
            background-color: #f53c3c;
        }

        #custom-media {
            background-color: #66cc99;
            color: white;
            min-width: 100px;
        }

        #custom-media.custom-spotify {
            background-color: #66cc99;
        }

        #custom-media.custom-vlc {
            background-color: #ffa000;
        }

        #temperature {
            background-color: #f0932b;
        }

        #temperature.critical {
            background-color: #eb4d4b;
        }

        #tray {
            background-color: #2980b9;
        }

        #tray > .passive {
            -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
            -gtk-icon-effect: highlight;
            background-color: #eb4d4b;
        }

        #idle_inhibitor {
            background-color: #2d3436;
        }

        #idle_inhibitor.activated {
            background-color: #ecf0f1;
            color: white;
        }

        #mpd {
            background-color: #66cc99;
            color: white;
        }

        #mpd.disconnected {
            background-color: #f53c3c;
        }

        #mpd.stopped {
            background-color: #90b1b1;
        }

        #mpd.paused {
            background-color: #51a37a;
        }

        #language {
            background: #00b093;
            color: white;
            padding: 0 5px;
            margin: 0 5px;
            min-width: 16px;
        }

        #keyboard-state {
            background: #97e1ad;
            color: white;
            padding: 0 10px;
        }

        #scratchpad {
            background: rgba(0, 0, 0, 0.2);
        }

        #scratchpad.empty {
        	background-color: transparent;
        }

        #privacy {
            padding: 0;
        }

        #privacy-item {
            padding: 0 5px;
            color: white;
        }

        #privacy-item.screenshare {
            background-color: #cf5700;
        }

        #privacy-item.audio-in {
            background-color: #1ca000;
        }

        #privacy-item.audio-out {
            background-color: #0069d4;
        }

        #custom-openfortivpn,
        #custom-openvpn-pub,
        #custom-openvpn-int {
          padding: 0 10px;
        }

        #custom-openfortivpn.on,
        #custom-openvpn-pub.on,
        #custom-openvpn-int.on  {
          color: white;  
          background-color: #990000;
        }

        #custom-openfortivpn.off,
        #custom-openvpn-pub.off,
        #custom-openvpn-int.off  {
          color: white;
          background-color: #006600;;
        }
      '';
    };
  };
}
