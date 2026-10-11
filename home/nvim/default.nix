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
    blink-cmp
    bufferline-nvim
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
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-dap-vscode-js
    nvim-lint
    nvim-lspconfig
    nvim-nio
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

    # used by the LazyVim language extras (lazy.lua)
    SchemaStore-nvim # json, yaml
    clangd_extensions-nvim # c, c++
    crates-nvim # rust (Cargo.toml)
    haskell-snippets-nvim
    haskell-tools-nvim
    nvim-dap-go
    nvim-dap-python
    omnisharp-extended-lsp-nvim # c#
    rustaceanvim
    venv-selector-nvim # python
    vim-dadbod # sql
    vim-dadbod-completion
    vim-dadbod-ui
    # plugins whose nixpkgs name differs from the name LazyVim uses
    {
      name = "typst-preview.nvim";
      path = typst-preview-nvim;
    }
    {
      name = "LuaSnip"; # for haskell-snippets
      path = luasnip;
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

  # ── Tree-sitter parsers + queries, pre-built (nothing is compiled) ──────
  # One folder with parser/*.so and queries/<lang>/, used as nvim-treesitter's
  # install_dir (lua/plugins/nix.lua). Only parsers in there count as
  # installed, and LazyVim only enables treesitter for installed ones.
  grammars = with pkgs.vimPlugins.nvim-treesitter-parsers; [
    # languages you write
    c
    c_sharp
    cpp
    css
    go
    gomod
    gosum
    gowork
    haskell
    html
    javascript
    jsdoc
    json
    json5
    markdown
    markdown_inline
    nix
    php
    php_only
    phpdoc
    python
    rust
    scss
    sql
    toml
    tsx
    typescript
    xml
    yaml
    # also used
    bash
    diff
    latex
    lua
    luadoc
    luap
    ninja
    printf
    query
    regex
    ron
    rst
    svelte
    typst
    vim
    vimdoc
    vue
  ];

  treesitter = pkgs.runCommand "nvim-treesitter-site" { } ''
    mkdir -p $out/parser
    for g in ${lib.concatMapStringsSep " " toString grammars}; do
      ln -s $g/parser/* $out/parser/
    done
    # the queries that belong to these parsers ship with nvim-treesitter
    ln -s ${pkgs.vimPlugins.nvim-treesitter}/runtime/queries $out/queries
  '';

  # Python for nvim-dap-python
  debugpy = pkgs.python3.withPackages (ps: [ ps.debugpy ]);
in
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    # keep the Python provider (the default changes to false with stateVersion 26.05)
    withPython3 = true;

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

      # TypeScript / JavaScript
      vtsls
      prettier

      # HTML / CSS / JSON (vscode-html/css/json-language-server)
      vscode-langservers-extracted
      fixjson
      jq

      # XML / YAML / TOML
      lemminx
      yaml-language-server
      taplo

      # Markdown
      marksman
      markdownlint-cli2
      markdown-toc
      mermaid-cli
      imagemagick

      # SQL
      sqlfluff

      # Python
      pyright
      ruff

      # C / C++ (clangd, clang-format; debugging uses codelldb below)
      clang-tools

      # Go
      go
      gopls
      gofumpt
      gotools # goimports
      golangci-lint
      delve
      gomodifytags
      impl

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
      rustfmt
      clippy

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
        debugpy = "${debugpy}/bin/python",
        treesitter = "${treesitter}",
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
