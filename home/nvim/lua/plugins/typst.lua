-- Typst live preview in the browser, cursor synced both ways.
return {
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    opts = {
      dependencies_bin = { tinymist = "tinymist" },
      open_cmd = "xdg-open %s",
    },
    keys = {
      { "<leader>tp", "<cmd>TypstPreview<cr>", desc = "Typst preview (browser)" },
      { "<leader>tt", "<cmd>TypstPreviewToggle<cr>", desc = "Toggle Typst preview" },
      { "<leader>ts", "<cmd>TypstPreviewSyncCursor<cr>", desc = "Sync preview to cursor" },
    },
  },
}
