{
  inputs,
  pkgs,
  ...
}:
{
  programs = {
    kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";
      font.name = "FiraCode Nerd Font";
      settings = {
        shell_integration = "enabled";
        allow_remote_control = "yes";
        listen_on = "unix:/tmp/kitty.sock";
      };
      extraConfig = ''
        action_alias kitty_scrollback_nvim kitten /nix/store/76xdicgz309fvl12j3chhcda697z4isw-lazy-plugins/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py
        map ctrl+shift+h kitty_scrollback_nvim
        map ctrl+shift+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
      '';
    };
  };
}
