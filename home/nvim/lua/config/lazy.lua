-- lazy.nvim setup. Plugins come from Nix (require("nix").plugins), so
-- lazy never downloads, updates or installs anything.
local nix = require("nix")
vim.opt.rtp:prepend(nix.lazy)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.dap.core" },
    -- languages: LSP, formatter, linter, debugger and treesitter settings.
    -- Their tools come from Nix (extraPackages in default.nix); the Mason
    -- parts of these extras are ignored because Mason is disabled.
    -- html, css and xml have no extra; they are set up in plugins/lsp.lua.
    { import = "lazyvim.plugins.extras.lang.clangd" }, -- c, c++
    { import = "lazyvim.plugins.extras.lang.dotnet" }, -- c#
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.haskell" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.nix" },
    { import = "lazyvim.plugins.extras.lang.php" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.sql" },
    { import = "lazyvim.plugins.extras.lang.toml" },
    { import = "lazyvim.plugins.extras.lang.typescript" }, -- typescript, javascript
    { import = "lazyvim.plugins.extras.lang.yaml" },
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
