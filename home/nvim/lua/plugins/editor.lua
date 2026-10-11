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

  -- calmer completion (blink.cmp, LazyVim's completion engine)
  -- everywhere: nothing preselected, so Enter only confirms an item you picked;
  --   no gray "ghost text" preview of a suggestion
  -- in prose (markdown, text, git commits): no popup while typing
  --   (<C-Space> opens it) and no words collected from the file
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      local prose = { markdown = true, ["markdown.mdx"] = true, text = true, gitcommit = true }

      opts.completion = opts.completion or {}
      opts.completion.list = { selection = { preselect = false, auto_insert = false } }
      opts.completion.ghost_text = { enabled = false }
      opts.completion.menu = opts.completion.menu or {}
      opts.completion.menu.auto_show = function()
        return not prose[vim.bo.filetype]
      end

      opts.sources = opts.sources or {}
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      for ft in pairs(prose) do
        opts.sources.per_filetype[ft] = { "lsp", "path" }
      end
    end,
  },
}
