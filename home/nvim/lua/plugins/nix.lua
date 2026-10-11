-- Things that differ because everything comes from Nix instead of Mason.
return {
  -- no Mason: LSPs, formatters and debuggers are in programs.neovim.extraPackages
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },

  -- no parser downloads: parsers + queries come pre-built from Nix.
  -- nvim-treesitter (main branch) only counts parsers in its install_dir,
  -- and LazyVim only turns on highlighting/indent/folds for counted ones,
  -- so install_dir points at the Nix folder (parser/ + queries/).
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.install_dir = require("nix").treesitter
      opts.ensure_installed = {}
    end,
  },

  -- Python debugging: a Python with debugpy from Nix
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup(require("nix").debugpy)
    end,
  },
}
