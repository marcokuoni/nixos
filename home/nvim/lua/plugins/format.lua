-- Formatters and linters per filetype.
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        php = { "pint", "php_cs_fixer", stop_after_first = true },
        json = { "prettierd", "prettier", "jq", stop_after_first = true },
        jsonc = { "biome", "fixjson", "prettierd", "prettier", stop_after_first = true },
        cs = { "csharpier" },
        -- typst is formatted by tinymist (plugins/lsp.lua)
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      -- php is linted by the phpactor LSP
      linters_by_ft = { php = {} },
    },
  },
}
