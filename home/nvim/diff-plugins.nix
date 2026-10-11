# lazyvim-diff-plugins: compare the plugins Nix provides with the plugins
# lazy.nvim loads. A plugin only in "lazy" is missing from `plugins` in
# default.nix (lazy can't download it, so it won't work).
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "lazyvim-diff-plugins";
      # uses your configured nvim from PATH (not a plain one from nixpkgs)
      text = ''
        # plugins lazy.nvim knows at runtime
        lazy_plugins() {
          nvim --headless \
            -c 'lua for _, p in ipairs(require("lazy").plugins()) do print(p.name) end' \
            -c 'qa!' 2>&1 \
            | grep -vxF 'lazy.nvim' \
            | sort
        }
        # plugins in the Nix plugin folder (require("nix").plugins, see default.nix)
        nix_plugins() {
          dir=$(nvim --headless -c 'lua io.stdout:write(require("nix").plugins)' -c 'qa!' 2>/dev/null)
          find "$dir" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort
        }
        diff -w -u --label nix <(nix_plugins) --label lazy <(lazy_plugins)
      '';
    })
  ];
}
