-- Language servers that need settings beyond LazyVim's defaults, plus the
-- languages without a LazyVim extra (html, css, xml).
-- The binaries come from Nix (programs.neovim.extraPackages).
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- from vscode-langservers-extracted
        html = {},
        cssls = {}, -- css, scss, less
        -- XML
        lemminx = {},
        omnisharp = {
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
        },
        -- the dotnet extra also starts the F# server; not installed, not needed
        fsautocomplete = { enabled = false },
        -- Typst: completion, hover, goto-def, formatting, PDF on every :w
        tinymist = {
          settings = {
            formatterMode = "typstyle",
            exportPdf = "onSave",
            semanticTokens = "enable",
          },
        },
      },
    },
  },
}
