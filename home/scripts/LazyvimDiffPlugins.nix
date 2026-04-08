{pkgs, ...}: {
  # lazyvim-diff-plugins: compare plugins known to Nix vs plugins loaded by lazy
  # useful for finding plugins lazy downloaded that should be added to the Nix config
  home.packages = [
    (pkgs.writeShellScriptBin "lazyvim-diff-plugins" ''
      #!/usr/bin/env bash
      # plugins as seen by lazy at runtime
      lazy_plugins() {
        nvim --headless \
          -c ':lua for _, plugin in ipairs(require("lazy").plugins()) do print(plugin.name) end' \
          -c 'q' 2>&1 \
          | grep -vxF 'lazy.nvim' \
          | sort
      }
      # plugins available in the nix linkFarm
      nix_plugins() {
        dir=$(awk -F'"' '/path = / {print $2}' ~/.config/nvim/init.lua)
        ls -1 "$dir" | sort
      }
      diff -w -u --label nix <(nix_plugins) --label lazy <(lazy_plugins)
    '')
  ];
}
