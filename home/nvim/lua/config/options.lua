-- Loaded by LazyVim before plugins. LazyVim's defaults:
-- https://www.lazyvim.org/configuration/general

-- Your login shell is nushell, but :!cmd and plugins expect POSIX syntax,
-- so nvim runs its internal commands with bash. Terminals still open nu
-- (see plugins/editor.lua).
vim.o.shell = require("nix").bash
