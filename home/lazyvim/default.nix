{
  inputs,
  pkgs,
  lib,
  nixvim,
  ...
}:
{
  # https://github.com/azuwis/lazyvim-nixvim/tree/master
  programs.nixvim = {
    enable = true;

    withRuby = false;

    extraPackages = with pkgs; [
      # LazyVim
      lua-language-server
      stylua
      fd
      fzf
      lazygit
      mermaid-cli
      tectonic
      ghostscript
      libgcc
      python313Packages.pylatexenc
      prettier
      shfmt
      nixfmt-rfc-style
      php83Packages.php-cs-fixer
      markdownlint-cli2
      ast-grep
      python3
      marksman
      fish
      nodejs_24
      rust-analyzer
      # Telescope
      ripgrep
    ];

    extraPlugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraConfigLua =
      let
        plugins = with pkgs.vimPlugins; [
          # LazyVim
          LazyVim
          bufferline-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          conform-nvim
          dashboard-nvim
          dressing-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          grug-far-nvim
          indent-blankline-nvim
          lazydev-nvim
          lualine-nvim
          luvit-meta
          neo-tree-nvim
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-snippets
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-treesitter-parsers.regex
          nvim-treesitter-parsers.latex
          nvim-treesitter-parsers.css
          nvim-treesitter-parsers.html
          nvim-treesitter-parsers.javascript
          # not in nix unstable nvim-treesitter-parsers.norg
          nvim-treesitter-parsers.scss
          nvim-treesitter-parsers.svelte
          nvim-treesitter-parsers.tsx
          nvim-treesitter-parsers.typst
          nvim-treesitter-parsers.vue
          nvim-treesitter-parsers.php
          nvim-treesitter-parsers.haskell
          nvim-treesitter-parsers.sql
          nvim-treesitter-parsers.bash
          nvim-ts-autotag
          nvim-dap
          persistence-nvim
          plenary-nvim
          snacks-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          ts-comments-nvim
          which-key-nvim
          none-ls-nvim
          vim-markdown-toc
          markdown-preview-nvim
          render-markdown-nvim
          {
            name = "catppuccin";
            path = catppuccin-nvim;
          }
          {
            name = "mini.ai";
            path = mini-nvim;
          }
          {
            name = "mini.icons";
            path = mini-nvim;
          }
          {
            name = "mini.pairs";
            path = mini-nvim;
          }
        ];
        mkEntryFromDrv =
          drv:
          if lib.isDerivation drv then
            {
              name = "${lib.getName drv}";
              path = drv;
            }
          else
            drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        require("lazy").setup({
          defaults = {
            lazy = true,
          },
          dev = {
            -- reuse files from pkgs.vimPlugins.*
            path = "${lazyPath}",
            patterns = { "" },
            -- fallback to download
            fallback = true,
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            -- The following configs are needed for fixing lazyvim on nix
            -- force enable telescope-fzf-native.nvim
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
            -- disable mason.nvim, use config.extraPackages
            { "williamboman/mason-lspconfig.nvim", enabled = false },
            { "williamboman/mason.nvim", enabled = false },
            -- uncomment to import/override with your plugins
            -- { import = "plugins" },
            {
              "folke/snacks.nvim",
              opts = {
                notifier = { enabled = true },

                -- show hidden files in snacks.explorer
                picker = {
                  sources = {
                    explorer = {
                      -- show hidden files like .env
                      hidden = true,
                      -- show files ignored by git like node_modules
                      ignored = true,
                    },
                  },
                },
              },
            },
            -- put this line at the end of spec to clear ensure_installed
            { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {
                "bash",
                "html",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "tsx",
                "typescript",
                "vim",
                "yaml",
                "tsx",
                "typescript",
              } end },
          },
        })
      '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
