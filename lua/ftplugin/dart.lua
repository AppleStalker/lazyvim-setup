return {
  "akinsho/flutter-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
  config = function()
    require("flutter-tools").setup({
      -- (uncomment for Windows)
      -- flutter_path = "C:/path/to/flutter/bin/flutter.bat", -- Uncomment if on Windows

      debugger = {
        enabled = true, -- Enable debug mode
        run_via_dap = true, -- Use DAP for running the app
        register_configurations = function(_)
          -- DAP Dart adapter configuration
          require("dap").adapters.dart = {
            type = "executable",
            command = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter",
            args = { "flutter" },
          }

          -- DAP configurations for Flutter (dart)
          require("dap").configurations.dart = {
            {
              type = "dart",
              request = "launch",
              name = "Launch Flutter App",
              dartSdkPath = "home/flutter/bin/cache/dart-sdk/", -- Update this path accordingly
              flutterSdkPath = "home/flutter", -- Update this path accordingly
              program = "${workspaceFolder}/lib/main.dart",
              cwd = "${workspaceFolder}",
            },
          }
          -- Uncomment if using a launch.json in VSCode setup
          -- require("dap.ext.vscode").load_launchjs()
        end,
      },

      dev_log = {
        enabled = false, -- Enable if you need debug logs
        open_cmd = "tabedit",
      },

      lsp = {
        on_attach = require("lvim.lsp").common_on_attach,
        capabilities = require("lvim.lsp").default_capabilities,
      },
    })
  end,
},
-- Dart syntax highlighting
{
  "dart-lang/dart-vim-plugin",
}
