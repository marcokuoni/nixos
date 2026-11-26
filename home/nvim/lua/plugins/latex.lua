-- LaTeX: vimtex (compile, view, motions, text objects), texlab (completion,
-- references, chktex) and LTeX+ (grammar + spelling via LanguageTool, offline).
-- The base setup comes from LazyVim's tex extra (lua/config/lazy.lua); this
-- file only adds to it. Binaries come from Nix (extraPackages in default.nix).
return {
  {
    "lervag/vimtex",
    -- init runs before vimtex loads, so these are seen on its first start
    init = function()
      -- zathura without xdotool: works on Wayland (niri). Forward search with
      -- <localleader>lv, inverse search with ctrl+click in zathura.
      vim.g.vimtex_view_method = "zathura_simple"
      -- inverse search starts a second nvim; it must be the Nix wrapper (the
      -- one on PATH) so it gets this config and finds vimtex
      vim.g.vimtex_callback_progpath = vim.fn.exepath("nvim")
      -- open the quickfix list on errors only, not on every warning
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_ignore_filters = {
        "Underfull",
        "Overfull",
        "specifier changed to",
        "Token not allowed in a PDF string",
      }
      -- table of contents (<localleader>lt) as a sidebar on the right
      vim.g.vimtex_toc_config = { split_pos = "vert rightbelow", split_width = 40 }
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              -- chktex (LaTeX style/typo linter) on open and save
              chktex = { onOpenAndSave = true, onEdit = false },
              diagnosticsDelay = 300,
              -- formatting is done by tex-fmt (plugins/format.lua)
              latexFormatter = "none",
              bibtexFormatter = "texlab",
            },
          },
        },

        -- LTeX+: LanguageTool grammar, style and spelling. Understands LaTeX,
        -- BibTeX and Typst, so commands and math are not flagged.
        -- Switch language per file with a magic comment, e.g.
        --   % LTeX: language=de-CH          (LaTeX)
        --   // LTeX: language=de-CH         (Typst)
        ltex_plus = {
          filetypes = { "tex", "plaintex", "bib", "typst", "gitcommit" },
          settings = {
            ltex = {
              language = "en-US",
              additionalRules = {
                -- stricter style rules (wordiness, repetition, passive …)
                enablePickyRules = true,
                -- catches German→English false friends ("become" vs "bekommen")
                motherTongue = "de-DE",
              },
              latex = {
                -- commands whose argument is not prose
                commands = {
                  ["\\cref{}"] = "dummy",
                  ["\\Cref{}"] = "dummy",
                  ["\\autoref{}"] = "dummy",
                  ["\\autocite{}"] = "dummy",
                  ["\\autocite[]{}"] = "dummy",
                  ["\\textcite{}"] = "dummy",
                  ["\\parencite{}"] = "dummy",
                  ["\\gls{}"] = "dummy",
                  ["\\Gls{}"] = "dummy",
                  ["\\glspl{}"] = "dummy",
                  ["\\acrshort{}"] = "dummy",
                  ["\\acrlong{}"] = "dummy",
                  ["\\todo{}"] = "ignore",
                  ["\\todo[]{}"] = "ignore",
                },
                environments = {
                  lstlisting = "ignore",
                  minted = "ignore",
                  verbatim = "ignore",
                  tikzpicture = "ignore",
                },
              },
            },
          },
        },
      },
    },
  },

  -- Makes the LTeX+ code actions "Add to dictionary", "Disable rule" and
  -- "Hide false positive" work, and keeps those lists across sessions in
  -- ~/.local/share/nvim/ltex/ (one file per language, shared by all projects).
  {
    "barreiroleo/ltex_extra.nvim",
    lazy = true,
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ltex_extra", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "ltex_plus" then
            return
          end
          vim.api.nvim_buf_call(args.buf, function()
            -- LTeX+ already spell checks; vim's checker would underline twice
            vim.opt_local.spell = false
            require("ltex_extra").setup({
              load_langs = { "en-US", "en-GB", "de-CH", "de-DE" },
              path = vim.fn.stdpath("data") .. "/ltex",
            })
          end)
        end,
      })
    end,
  },
}
