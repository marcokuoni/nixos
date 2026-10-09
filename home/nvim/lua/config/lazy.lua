-- lazy.nvim setup. Plugins come from Nix (require("nix").plugins), so
-- lazy never downloads, updates or installs anything.
local nix = require("nix")
vim.opt.rtp:prepend(nix.lazy)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.dap.core" },
    -- PHP extra expects Mason; phpactor is set up in plugins/lsp.lua instead
    { import = "lazyvim.plugins.extras.lang.php", enabled = false },
    -- everything in lua/plugins/*.lua
    { import = "plugins" },
  },
  defaults = { lazy = true },
  dev = {
    path = nix.plugins,
    patterns = { "" }, -- every plugin comes from the Nix folder
    fallback = true,
  },
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  rocks = { enabled = false },
  readme = { enabled = false },
  performance = {
    reset_packpath = true,
    rtp = { reset = true },
  },
})
