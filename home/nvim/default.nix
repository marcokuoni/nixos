# Neovim = LazyVim, fully offline.
#
# Nix only does three things here:
#   1. install nvim + every LSP / formatter / debugger it calls
#   2. provide all plugins and tree-sitter parsers from nixpkgs
#   3. link the plain Lua config in ./lua into ~/.config/nvim/lua
#
# Everything about *how* nvim behaves lives in ./lua — edit those files
# like any normal LazyVim config.
{
  lib,
  pkgs,
  ...
}:
let
  # ── Plugins lazy.nvim manages (all from nixpkgs, nothing downloaded) ────
  # lazy finds each one by its repo name in this folder.
  plugins = with pkgs.vimPlugins; [
    LazyVim
    base16-nvim
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
    markdown-preview-nvim
    neo-tree-nvim
    noice-nvim
    none-ls-nvim
    nui-nvim
    nvim-cmp
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-dap-vscode-js
    nvim-lint
    nvim-lspconfig
    nvim-nio
    nvim-snippets
    nvim-treesitter
    nvim-treesitter-textobjects
    nvim-ts-autotag
    persistence-nvim
    phpactor
    plenary-nvim
    render-markdown-nvim
    snacks-nvim
    telescope-fzf-native-nvim
    telescope-nvim
    todo-comments-nvim
    tokyonight-nvim
    trouble-nvim
    ts-comments-nvim
    vim-markdown-toc
    which-key-nvim
    # plugins whose nixpkgs name differs from the name LazyVim uses
    {
      name = "typst-preview.nvim";
      path = typst-preview-nvim;
    }
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

  lazyPlugins = pkgs.linkFarm "lazy-plugins" (
    map (
      p:
      if lib.isDerivation p then
        {
          name = lib.getName p;
          path = p;
        }
      else
        p
    ) plugins
  );

  # ── Tree-sitter parsers, pre-built (nvim-treesitter never compiles) ─────
  parsers = pkgs.symlinkJoin {
    name = "nvim-treesitter-parsers";
    paths = with pkgs.vimPlugins.nvim-treesitter-parsers; [
      bash
      c_sharp
      css
      haskell
      html
      javascript
      json
      latex
      lua
      markdown
      markdown_inline
      nix
      php
      regex
      rust
      scss
      sql
      svelte
      tsx
      typescript
      typst
      vue
      yaml
    ];
  };
in
{
  programs.neovim = {
    enable = true;
    withRuby = false;

    # Everything nvim calls: LSPs, formatters, linters, debuggers.
    # They are only on nvim's PATH, not in your shell.
    extraPackages = with pkgs; [
      # LazyVim core
      ast-grep
      fd
      fzf
      lazygit
      ripgrep
      gcc # some plugins build small native parts
      libgcc
      tree-sitter
      nodejs_24
      python3
      fish # used by some LazyVim extras internally

      # Lua
      lua-language-server
      stylua

      # Nix
      nil
      nixfmt
      statix

      # Web / JSON / Markdown
      vtsls
      vscode-json-languageserver
      prettier
      fixjson
      jq
      marksman
      markdownlint-cli2
      mermaid-cli
      imagemagick

      # PHP
      phpactor
      php83Packages.php-cs-fixer
      php84Packages.composer

      # C#
      omnisharp-roslyn
      csharpier
      dotnet-sdk_10
      netcoredbg

      # Rust
      cargo
      rustc
      rust-analyzer

      # Haskell
      haskell-language-server
      hlint
      haskellPackages.fourmolu
      haskellPackages.cabal-fmt
      haskellPackages.fast-tags

      # Typst
      typst
      tinymist
      typstyle

      # LaTeX
      tectonic
      ghostscript
      python313Packages.pylatexenc

      # Shell
      shfmt
    ];

    # Hand the Nix store paths the Lua config needs over to Lua
    # (as `require("nix")`), then start lazy.nvim from lua/config/lazy.lua.
    initLua = ''
      package.loaded["nix"] = {
        lazy = "${pkgs.vimPlugins.lazy-nvim}",
        plugins = "${lazyPlugins}",
        bash = "${lib.getExe pkgs.bash}",
        php_debug = "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js",
        codelldb = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb",
        js_debug = "${pkgs.vscode-js-debug}/share/vscode/extensions/ms-vscode.js-debug",
      }
      require("config.lazy")
    '';
  };

  xdg.configFile = {
    # the Lua config (linked file by file, so lua/ stays writable —
    # Noctalia writes lua/matugen.lua in there)
    "nvim/lua" = {
      source = ./lua;
      recursive = true;
    };
    # linked file by file too, so an existing parser/ folder is never in the way
    "nvim/parser" = {
      source = "${parsers}/parser";
      recursive = true;
    };

    # Noctalia fills lua/matugen-template.lua with the current wallpaper colors
    # and tells nvim to reload them
    "noctalia/user-templates.toml".text = ''
      [templates.nvim-base16]
      input_path = "~/.config/nvim/lua/matugen-template.lua"
      output_path = "~/.config/nvim/lua/matugen.lua"
      post_hook = 'pkill -SIGUSR1 nvim'
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
