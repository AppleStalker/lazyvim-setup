vim.api.nvim_create_augroup("DapGroup", { clear = true })

local function navigate(args)
  local buffer = args.buf
  local wid = nil
  for _, win_id in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win_id) == buffer then
      wid = win_id
    end
  end
  if wid then
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(wid) then
        vim.api.nvim_set_current_win(wid)
      end
    end)
  end
end

local function create_nav_options(name)
  return { group = "DapGroup", pattern = string.format("*%s*", name), callback = navigate }
end

return {
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    config = function()
      local dap = require("dap")
      dap.set_log_level("DEBUG")

      vim.keymap.set("n", "<F8>", dap.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Conditional Breakpoint" })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
      vim.api.nvim_create_autocmd("BufWinEnter", create_nav_options("dap-repl"))
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "java-debug-adapter", "dart-code", "codelldb", "delve", "rust-analyzer" },
      })
    end,
  },
  -- LuaSnip Configuration
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")
      ls.filetype_extend("javascript", { "jsdoc" })
      ls.filetype_extend("c", { "cpp" })
      ls.filetype_extend("cpp", { "c" })
      ls.filetype_extend("go", { "golang" })
      ls.filetype_extend("java", { "javadoc" })
      ls.filetype_extend("rust", { "rustdoc" })
      ls.filetype_extend("dart", { "flutter" })
      ls.filetype_extend("solidity", { "sol" })

      vim.keymap.set({ "i" }, "<C-s>e", function()
        ls.expand()
      end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-s>;", function()
        ls.jump(1)
      end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-s>,", function()
        ls.jump(-1)
      end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-E>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true })
    end,
  },
  -- Debug Adapters for Various Languages
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      -- Java Debug Adapter
      dap.adapters.java = function(callback)
        callback({ type = "server", host = "127.0.0.1", port = 5005 })
      end
      dap.configurations.java = {
        { type = "java", request = "attach", name = "Attach to JVM", hostName = "127.0.0.1", port = 5005 },
      }
      -- C/C++ (codelldb)
      dap.adapters.codelldb = {
        type = "server",
        port = "13000",
        executable = {
          command = "codelldb",
          args = { "--port", "13000" },
        },
      }
      dap.configurations.c = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.cpp = dap.configurations.c
      -- Golang (delve)
      dap.adapters.delve = {
        type = "server",
        port = "2345",
        executable = {
          command = "dlv",
          args = { "dap", "--listen=127.0.0.1:2345" },
        },
      }
      dap.configurations.go = {
        {
          type = "delve",
          name = "Debug",
          request = "launch",
          program = "${file}",
        },
      }
      -- Rust (rust-analyzer via codelldb)
      dap.configurations.rust = dap.configurations.c
      -- Flutter Debug Adapter
      dap.adapters.flutter = {
        type = "executable",
        command = "flutter",
        args = { "debug_adapter" },
      }
      dap.configurations.dart = {
        {
          type = "flutter",
          request = "launch",
          name = "Launch Flutter App",
          program = "${workspaceFolder}/lib/main.dart",
        },
      }
    end,
  },
}
