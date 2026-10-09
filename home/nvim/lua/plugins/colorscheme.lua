-- Colors follow the wallpaper: Noctalia writes lua/matugen.lua from
-- lua/matugen-template.lua. Without it, catppuccin is used.
local function matugen()
  local ok, m = pcall(require, "matugen")
  if ok then
    m.setup()
  end
  return ok
end

return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = matugen,
  },
  { "catppuccin/nvim", name = "catppuccin" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        if not matugen() then
          vim.cmd.colorscheme("catppuccin")
        end
      end,
    },
  },
}
