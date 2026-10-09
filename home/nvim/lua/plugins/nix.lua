-- Things that differ because everything comes from Nix instead of Mason.
return {
  -- no Mason: LSPs, formatters and debuggers are in programs.neovim.extraPackages
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },

  -- no parser downloads: they are linked to ~/.config/nvim/parser by Nix
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = {}
      opts.auto_install = false
    end,
  },

  -- the native fzf part is pre-built by Nix
  { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
}
