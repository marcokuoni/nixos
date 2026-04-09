{
  pkgs,
  lib,
  ...
}:
{
  # Noctalia matugen template — Noctalia writes matugen.lua at runtime from this
  # template whenever the color scheme changes, then signals nvim to reload it
  home.file.".config/noctalia/user-templates.toml".text = ''
    [templates.nvim-base16]
    input_path = "~/.config/nvim/lua/matugen-template.lua"
    output_path = "~/.config/nvim/lua/matugen.lua"
    post_hook = 'pkill -SIGUSR1 nvim'
  '';

  programs.nixvim = {
    enable = true;
    withRuby = false;

    # ── External tools ────────────────────────────────────────────────────────
    # All LSPs, formatters, linters and DAP adapters come from Nix — no Mason
    extraPackages = with pkgs; [
      # LazyVim core tools
      lua-language-server
      stylua # Lua formatter
      fd # faster find (telescope)
      fzf # fuzzy finder
      lazygit # git TUI (snacks integration)
      mermaid-cli # diagram rendering in markdown
      tectonic # LaTeX compiler
      ghostscript # PDF/PS processing
      libgcc
      python313Packages.pylatexenc # LaTeX → unicode in nvim
      prettier
      shfmt # shell formatter
      nixfmt # Nix formatter
      php83Packages.php-cs-fixer
      markdownlint-cli2
      ast-grep # structural code search
      python3
      marksman # Markdown LSP
      fish # used by some LazyVim extras internally
      nodejs_24
      rust-analyzer
      php84Packages.composer
      phpactor # PHP LSP (Mason-free)

      # Telescope
      ripgrep

      # LSPs
      vtsls # TypeScript/JS LSP
      vscode-json-languageserver

      # DAP adapters (pulled from nixpkgs instead of Mason)
      vscode-extensions.xdebug.php-debug
      vscode-js-debug

      # Haskell
      haskell-language-server
      haskellPackages.fourmolu # Haskell formatter
      haskellPackages.cabal-fmt
      haskellPackages.fast-tags

      # Nix
      nil # Nix LSP
      statix # Nix linter

      # Tree-sitter
      tree-sitter
      gcc # needed to compile tree-sitter parsers

      # Formatters
      fixjson
      jq
      imagemagick

      # C#
      omnisharp-roslyn
      csharpier
      dotnet-sdk_10
    ];

    # ── Pre-compiled tree-sitter parsers ──────────────────────────────────────
    # Provided by Nix so tree-sitter never tries to compile them at runtime
    extraFiles = {
      "parser/haskell.so".source = "${pkgs.vimPlugins.nvim-treesitter-parsers.haskell}/parser/haskell.so";
      "parser/bash.so".source = "${pkgs.vimPlugins.nvim-treesitter-parsers.bash}/parser/bash.so";
      "parser/regex.so".source = "${pkgs.vimPlugins.nvim-treesitter-parsers.regex}/parser/regex.so";
      "parser/html.so".source = "${pkgs.vimPlugins.nvim-treesitter-parsers.html}/parser/html.so";
      "parser/latex.so".source = "${pkgs.vimPlugins.nvim-treesitter-parsers.latex}/parser/latex.so";
      "parser/yaml.so".source = "${pkgs.vimPlugins.nvim-treesitter-parsers.yaml}/parser/yaml.so";
      "parser/css.so".source = "${pkgs.vimPlugins.nvim-treesitter-parsers.css}/parser/css.so";
      "parser/javascript.so".source =
        "${pkgs.vimPlugins.nvim-treesitter-parsers.javascript}/parser/javascript.so";
      "parser/c_sharp.so".source = "${pkgs.vimPlugins.nvim-treesitter-parsers.c_sharp}/parser/c_sharp.so";

      # matugen-template.lua is the source template — Noctalia reads this and
      # writes matugen.lua with actual color values at runtime
      "lua/matugen-template.lua".text = ''
        local M = {}

        function M.setup()
          require('base16-colorscheme').setup {
            base00 = '{{colors.surface.default.hex}}',
            base01 = '{{colors.surface_container.default.hex}}',
            base02 = '{{colors.surface_container_high.default.hex}}',
            base03 = '{{colors.outline.default.hex}}',
            base04 = '{{colors.on_surface_variant.default.hex}}',
            base05 = '{{colors.on_surface.default.hex}}',
            base06 = '{{colors.on_surface.default.hex}}',
            base07 = '{{colors.on_background.default.hex}}',
            base08 = '{{colors.error.default.hex}}',
            base09 = '{{colors.tertiary.default.hex}}',
            base0A = '{{colors.secondary.default.hex}}',
            base0B = '{{colors.primary.default.hex}}',
            base0C = '{{colors.tertiary_fixed_dim.default.hex}}',
            base0D = '{{colors.primary_fixed_dim.default.hex}}',
            base0E = '{{colors.secondary_fixed_dim.default.hex}}',
            base0F = '{{colors.error_container.default.hex}}',
          }
        end

        -- Listen for SIGUSR1 from Noctalia's post_hook to reload colors live
        local signal = vim.uv.new_signal()
        signal:start(
          'sigusr1',
          vim.schedule_wrap(function()
            package.loaded['matugen'] = nil
            require('matugen').setup()
          end)
        )

        return M
      '';
    };

    # ── Plugins loaded outside lazy ───────────────────────────────────────────
    # lazy-nvim itself and base16-nvim need to be available before lazy bootstraps
    extraPlugins = with pkgs.vimPlugins; [
      lazy-nvim
      base16-nvim
      nvim-treesitter-parsers.c_sharp
    ];

    extraConfigLua =
      let
        # All plugins that lazy will manage — sourced from nixpkgs instead of
        # being downloaded at runtime. This is the key to a fully offline setup.
        plugins = with pkgs.vimPlugins; [
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
          nvim-dap-ui
          nvim-nio
          nvim-dap-virtual-text
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
          phpactor
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

        # convert derivations to { name, path } entries for linkFarm
        mkEntryFromDrv =
          drv:
          if lib.isDerivation drv then
            {
              name = "${lib.getName drv}";
              path = drv;
            }
          else
            drv;

        # symlink farm that lazy uses as its local dev path —
        # means lazy finds all plugins without network access
        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        require("lazy").setup({
          defaults = { lazy = true },
          rocks = { enabled = false },
          dev = {
            -- point lazy at the nix-built plugin farm
            path = "${lazyPath}",
            patterns = { "" },
            fallback = true,
          },
          spec = {
            {
              "LazyVim/LazyVim",
              import = "lazyvim.plugins",
              opts = {
                -- use Noctalia's matugen colors if available, fallback to catppuccin
                colorscheme = function()
                  local ok, matugen = pcall(require, 'matugen')
                  if ok then
                    matugen.setup()
                  else
                    vim.cmd.colorscheme("catppuccin")
                  end
                end,
              },
            },

            -- base16-nvim loads first so matugen colors apply immediately
            {
              "RRethy/base16-nvim",
              lazy = false,
              priority = 1000,
              config = function()
                local ok, _ = pcall(require, 'matugen')
                if ok then require('matugen').setup() end
              end,
            },

            { "catppuccin/nvim", name = "catppuccin" },

            -- telescope fzf native works fine from nix
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },

            -- ── No Mason — all tools come from Nix ─────────────────────────
            { "mason-org/mason.nvim",           enabled = false },
            { "mason-org/mason-lspconfig.nvim", enabled = false },
            { "jay-babu/mason-nvim-dap.nvim",   enabled = false },

            -- disable LazyVim's PHP extra (expects Mason for phpactor)
            { import = "lazyvim.plugins.extras.lang.php", enabled = false },

            -- DAP core (nvim-dap + dap-ui) without Mason
            { import = "lazyvim.plugins.extras.dap.core", enabled = true },

            -- LSP servers configured directly (no Mason)
            {
              "neovim/nvim-lspconfig",
              opts = {
                servers = {
                  phpactor = {
                    cmd = { "phpactor", "language-server" },
                  },
                  omnisharp = {
                    enable_roslyn_analyzers = true,
                    organize_imports_on_format = true,
                    enable_import_completion = true,
                  },
                },
              },
            },

            -- ── PHP / Xdebug DAP ───────────────────────────────────────────
            {
              "mfussenegger/nvim-dap",
              dependencies = {
                "rcarriga/nvim-dap-ui",
                "nvim-neotest/nvim-nio",
                "theHamsta/nvim-dap-virtual-text",
              },
              ft = { "php" },
              config = function()
                local dap    = require("dap")
                local dapui  = require("dapui")

                local php_debug_js = "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js"

                dap.adapters.php = {
                  type    = "executable",
                  command = "node",
                  args    = { php_debug_js },
                  options = { detached = false },
                }
                dap.adapters["php-debug-adapter"] = dap.adapters.php

                dapui.setup()
                dap.listeners.after.event_initialized["dapui_open"]  = function() dapui.open()  end
                dap.listeners.before.event_terminated["dapui_close"] = function() dapui.close() end
                dap.listeners.before.event_exited["dapui_close"]     = function() dapui.close() end

                vim.keymap.set("n", "<F5>",  function() dap.continue()          end)
                vim.keymap.set("n", "<F9>",  function() dap.toggle_breakpoint()  end)
                vim.keymap.set("n", "<F10>", function() dap.step_over()          end)
                vim.keymap.set("n", "<F11>", function() dap.step_into()          end)
                vim.keymap.set("n", "<F12>", function() dap.step_out()           end)
              end,
            },

            -- ── JS / Node / Chrome DAP ─────────────────────────────────────
            {
              "mxsdev/nvim-dap-vscode-js",
              dependencies = { "mfussenegger/nvim-dap" },
              ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
              config = function()
                local debugger_path = "${pkgs.vscode-js-debug}/share/vscode/extensions/ms-vscode.js-debug"

                require("dap-vscode-js").setup({
                  debugger_path = debugger_path,
                  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "pwa-extensionHost" },
                })
              end,
            },

            -- snacks: notifier replaces vim.notify, picker for file explorer
            {
              "folke/snacks.nvim",
              opts = {
                terminal = { enabled = true },
                notifier = { enabled = true },
                picker = {
                  sources = {
                    explorer = { hidden = true, ignored = true },
                  },
                },
              },
              init = function()
                -- if launched from ghostty as a terminal replacement, open fullscreen
                if vim.env.NVIM_FULL_TERMINAL == "1" then
                  vim.api.nvim_create_autocmd("UIEnter", {
                    once = true,
                    callback = function()
                      vim.schedule(function()
                        Snacks.terminal(nil, {
                          win = {
                            position = "float",
                            width = 0,
                            height = 0,
                            border = "none",
                          }
                        })
                      end)
                    end,
                  })
                end
              end,
              keys = {
                { "<leader>t", function() Snacks.terminal() end, desc = "Toggle Terminal" },
              },
            },

            -- formatters per filetype — all binaries come from extraPackages above
            {
              "stevearc/conform.nvim",
              optional = true,
              opts = {
                formatters_by_ft = {
                  lua        = { "stylua" },
                  javascript = { "prettierd", "prettier", stop_after_first = true },
                  php        = { "pint", "php_cs_fixer", stop_after_first = true },
                  json       = { "prettierd", "prettier", "jq", stop_after_first = true },
                  jsonc      = { "biome", "fixjson", "prettierd", "prettier", stop_after_first = true },
                  cs         = { "csharpier" },
                },
              },
            },

            {
              "mfussenegger/nvim-lint",
              optional = true,
              opts = {
                -- php linting handled by phpactor LSP instead
                linters_by_ft = { php = {} },
              },
            },

            -- disable auto-install — all parsers come from Nix
            {
              "nvim-treesitter/nvim-treesitter",
              opts = function(_, opts)
                opts.ensure_installed = {}
                opts.auto_install     = false
              end,
            },

            -- disable autocomplete popup — trigger manually with C-n/C-p
            {
              "hrsh7th/nvim-cmp",
              opts = function(_, opts)
                opts.completion = { autocomplete = false }
              end,
            },
          },
        })
      '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
