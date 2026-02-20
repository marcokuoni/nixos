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
      nixfmt
      php83Packages.php-cs-fixer
      markdownlint-cli2
      ast-grep
      python3
      marksman
      fish
      nodejs_24
      rust-analyzer
      php84Packages.composer
      phpactor
      # Telescope
      ripgrep
      vtsls
      vscode-json-languageserver
      vscode-extensions.xdebug.php-debug
      vscode-js-debug
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
          nvim-dap-ui
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

            -- Nix fixes
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },

            -- ❌ No Mason anywhere
            { "williamboman/mason.nvim", enabled = false },
            { "williamboman/mason-lspconfig.nvim", enabled = false },
            { "jay-babu/mason-nvim-dap.nvim", enabled = false },

            -- ❌ Disable LazyVim's PHP extra (it expects Mason)
            { import = "lazyvim.plugins.extras.lang.php", enabled = false },

            -- ✅ Enable LazyVim’s DAP extra so <leader>d shows up
            { import = "lazyvim.plugins.extras.dap.core" },

            -- (optional) PHP LSP without Mason: use phpactor from Nix
            {
              "neovim/nvim-lspconfig",
              opts = {
                servers = {
                  phpactor = {
                    cmd = { "phpactor", "language-server" },
                  },
                },
              },
            },

            -- =========================
            -- PHP / Xdebug (no Mason)
            -- =========================
            {
              "mfussenegger/nvim-dap",
              dependencies = {
                "rcarriga/nvim-dap-ui",
                "theHamsta/nvim-dap-virtual-text",
              },
              ft = { "php" }, -- load when opening PHP
              config = function()
                -- ensure we register the adapter when PHP is opened
                vim.api.nvim_create_autocmd("FileType", {
                  pattern = "php",
                  once = true,
                  callback = function()
                    local dap = require("dap")
                    local dapui = require("dapui")

                    -- VSCode Xdebug adapter from Nixpkgs
                    local php_debug_js = "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js"

                    if not dap.adapters.php then
                      dap.adapters.php = {
                        type = "executable",
                        command = "node",
                        args = { php_debug_js },
                        options = { detached = false },
                      }
                    end

                    dapui.setup()
                    dap.listeners.after.event_initialized["dapui_open"] = function() dapui.open() end
                    dap.listeners.before.event_terminated["dapui_close"] = function() dapui.close() end
                    dap.listeners.before.event_exited["dapui_close"] = function() dapui.close() end

                    -- handy keys
                    vim.keymap.set("n", "<F5>", function() dap.continue() end)
                    vim.keymap.set("n", "<F9>", function() dap.toggle_breakpoint() end)
                    vim.keymap.set("n", "<F10>", function() dap.step_over() end)
                    vim.keymap.set("n", "<F11>", function() dap.step_into() end)
                    vim.keymap.set("n", "<F12>", function() dap.step_out() end)
                  end,
                })
              end,
            },

            -- ======================================
            -- JS / Node / Chrome (no Mason)
            -- ======================================
            {
              "mxsdev/nvim-dap-vscode-js",
              dependencies = { "mfussenegger/nvim-dap" },
              ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
              config = function()
                -- VSCode js-debug extension from Nixpkgs
                local debugger_path = "${pkgs.vscode-js-debug}/share/vscode/extensions/ms-vscode.js-debug"

                require("dap-vscode-js").setup({
                  debugger_path = debugger_path,
                  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "pwa-extensionHost" },
                })

                local dap = require("dap")
                local pick = require("dap.utils").pick_process

                local js_like = { "javascript", "typescript", "javascriptreact", "typescriptreact" }

                for _, lang in ipairs(js_like) do
                end
              end,
            },

            -- your other extras & tweaks...
            {
              "folke/snacks.nvim",
              opts = {
                notifier = { enabled = true },
                picker = {
                  sources = {
                    explorer = { hidden = true, ignored = true },
                  },
                },
              },
            },
            {
              "stevearc/conform.nvim",
              optional = true,
              opts = {
                formatters_by_ft = {
                  lua = { "stylua" },
                  javascript = { "prettierd", "prettier", stop_after_first = true },
                  php = { "pint", "php_cs_fixer", stop_after_first = true },
                  json  = { "prettierd", "prettier", "jq", stop_after_first = true },
                  jsonc = { "biome", "fixjson", "prettierd", "prettier", stop_after_first = true },
                },
              },
            },
            {
              "mfussenegger/nvim-lint",
              optional = true,
              opts = {
                linters_by_ft = { php = {} },
              },
            },
            {
              "mikesmithgh/kitty-scrollback.nvim",
              lazy = true,
              cmd = {
                "KittyScrollbackGenerateKittens",
                "KittyScrollbackCheckHealth",
                "KittyScrollbackGenerateCommandLineEditing",
              },
              config = function()
                require("kitty-scrollback").setup({})
              end,
            },

            -- keep treesitter ensure_installed cleared
            { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end },
          },
        })
      '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
