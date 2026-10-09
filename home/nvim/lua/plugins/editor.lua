return {
  -- snacks: notifications, file explorer, terminal
  {
    "folke/snacks.nvim",
    opts = {
      notifier = { enabled = true },
      -- every snacks terminal (<C-/>, <leader>ft, <leader>t) opens nushell
      terminal = { enabled = true, shell = "nu" },
      picker = {
        sources = {
          explorer = { hidden = true, ignored = true },
        },
      },
    },
    keys = {
      { "<leader>t", function() Snacks.terminal() end, desc = "Toggle Terminal" },
    },
  },

  -- calmer completion for writing: no popup while typing (<C-Space> opens it),
  -- nothing preselected, Enter only confirms an item you picked
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.completion = {
        autocomplete = false,
        completeopt = "menu,menuone,noselect",
      }
      opts.preselect = cmp.PreselectMode.None
      opts.mapping["<CR>"] = cmp.mapping.confirm({ select = false })
      return opts
    end,
  },
}
