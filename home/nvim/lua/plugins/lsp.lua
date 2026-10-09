-- Language servers that need settings beyond LazyVim's defaults.
-- The binaries come from Nix (programs.neovim.extraPackages).
return {
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
