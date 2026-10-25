-- .waa board descriptions: filetype, syntax highlighting and waa-lsp
-- (diagnostics, hover with the WIT docs and datasheet notes, go to
-- definition, completion). The plugin comes from the board flake
-- (plugins in default.nix); it finds the project's WIT through the
-- waac.args next to setup.waa.
return {
  -- tiny, and needed before the first .waa file is opened
  { "marcokuoni/waa.nvim", lazy = false },
}
