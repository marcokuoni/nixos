# beamer-mirror: switch on the HDMI output and mirror the laptop screen to it.
# (Mod+P in niri mirrors the focused output instead.)
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "beamer-mirror";
      runtimeInputs = with pkgs; [
        wlr-randr
        wl-mirror
      ];
      text = ''
        wlr-randr --output HDMI-A-1 --on
        wl-mirror eDP-1 &
        sleep 0.5
      '';
    })
  ];
}
