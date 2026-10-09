-- Debugging for PHP (Xdebug), Rust (codelldb), C# (netcoredbg) and JS/TS.
-- Adapters come from Nix; their paths are in require("nix").
--
-- Keep all languages in this ONE nvim-dap spec: lazy.nvim merges specs for
-- the same plugin and only the last `config` wins.
local nix = require("nix")

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    ft = { "php", "rust", "cs" },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP step out" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- PHP / Xdebug
      dap.adapters.php = {
        type = "executable",
        command = "node",
        args = { nix.php_debug },
        options = { detached = false },
      }
      dap.adapters["php-debug-adapter"] = dap.adapters.php

      -- Rust / codelldb
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = nix.codelldb,
          args = { "--port", "${port}" },
        },
      }
      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            vim.fn.system("cargo build")
            return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- C# / netcoredbg
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }
      dap.adapters.netcoredbg = dap.adapters.coreclr
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch (build first)",
          request = "launch",
          program = function()
            vim.notify("dotnet build …")
            local out = vim.fn.system("dotnet build")
            if vim.v.shell_error ~= 0 then
              vim.notify(out, vim.log.levels.ERROR)
              return dap.ABORT
            end
            return vim.fn.input("DLL: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
        },
        {
          type = "coreclr",
          name = "Attach to process",
          request = "attach",
          processId = function()
            return require("dap.utils").pick_process()
          end,
        },
      }

      -- open/close the UI with the session
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_open"] = dapui.open
      dap.listeners.before.event_terminated["dapui_close"] = dapui.close
      dap.listeners.before.event_exited["dapui_close"] = dapui.close
    end,
  },

  -- JS / TS (Node, Chrome)
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    config = function()
      require("dap-vscode-js").setup({
        debugger_path = nix.js_debug,
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "pwa-extensionHost" },
      })
    end,
  },
}
