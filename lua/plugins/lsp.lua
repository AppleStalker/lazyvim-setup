return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "stevearc/conform.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp",
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
    "j-hui/fidget.nvim",
  },

  config = function()
    local lspconfig = require("lspconfig")
    local blink_cmp = require("blink.cmp")

    local capabilities = blink_cmp.get_lsp_capabilities()

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "gopls",
        "clangd",
        "jdtls",
        "dartls",
        "solidity_ls",
        "tsserver",
        "tailwindcss",
        "astro",
      },
      handlers = {
        function(server_name) -- Default handler for all servers
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
          })
        end,

        -- Java Configuration (JDTLS)
        ["jdtls"] = function()
          local lspconfig = require("lspconfig")
          local blink_cmp = require("blink.cmp")

          local capabilities = blink_cmp.get_lsp_capabilities()
          local mason_jdtls_path = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls")
          local equinox_launcher = vim.fn.glob(mason_jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

          -- ✅ Find Java version (use 23 if available, else 17)
          local java_paths = {
            "/usr/lib/jvm/java-23-openjdk/bin/java",
            "/usr/lib/jvm/java-17-openjdk/bin/java",
          }

          local java_cmd = nil
          for _, path in ipairs(java_paths) do
            if vim.fn.executable(path) == 1 then
              java_cmd = path
              break
            end
          end

          if not java_cmd then
            vim.notify("⚠️ JDTLS Error: No suitable Java version found (expected 23 or 17)", vim.log.levels.ERROR)
            return
          end

          -- ✅ Root detection: Use Main.java, .git, pom.xml, build.gradle, or fallback to current dir
          local function find_root()
            return lspconfig.util.root_pattern("Main.java", "pom.xml", "build.gradle", ".git")(vim.fn.getcwd())
              or vim.fn.getcwd()
          end

          -- ✅ JDTLS Setup
          lspconfig.jdtls.setup({
            capabilities = capabilities,
            cmd = {
              java_cmd,
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dlog.level=ALL",
              "-Xmx1G",
              "--add-modules=ALL-SYSTEM",
              "--add-opens",
              "java.base/java.util=ALL-UNNAMED",
              "--add-opens",
              "java.base/java.lang=ALL-UNNAMED",
              "-jar",
              equinox_launcher,
              "-configuration",
              mason_jdtls_path .. "/config_linux",
              "-data",
              mason_jdtls_path .. "/workspace/",
            },
            root_dir = find_root(), -- ✅ Automatically detects project root
            filetypes = { "java" },
          })
        end,

        -- Dart Configuration
        ["dartls"] = function()
          lspconfig.dartls.setup({
            capabilities = capabilities,
            cmd = { "dart", "language-server" },
            filetypes = { "dart" },
            init_options = {
              onlyAnalyzeProjectsWithOpenFiles = false,
              suggestFromUnimportedLibraries = true,
              closingLabels = true,
            },
            settings = {
              dart = {
                updateImportsOnRename = true,
                completeFunctionCalls = true,
                showTodos = true,
              },
            },
            on_attach = function(client, bufnr)
              if client.server_capabilities.documentFormattingProvider then
                vim.api.nvim_create_autocmd("BufWritePre", {
                  buffer = bufnr,
                  callback = function()
                    vim.lsp.buf.format({ async = false })
                  end,
                })
              end
            end,
          })
        end,

        -- Solidity Configuration
        ["solidity_ls"] = function()
          lspconfig.solidity_ls.setup({
            cmd = { "npx", "solidity-ls", "--stdio" },
            filetypes = { "solidity" },
            settings = {},
          })
        end,

        -- Solidity Linter: Solhint (via efm-langserver)
        ["efm"] = function()
          lspconfig.efm.setup({
            init_options = { documentFormatting = true },
            filetypes = { "solidity" },
            settings = {
              rootMarkers = { ".git/" },
              languages = {
                solidity = {
                  {
                    lintStdin = true,
                    lintIgnoreExitCode = true,
                    lintCommand = "solhint --stdin --format stylish",
                    lintFormats = {
                      "%#%l:%c %#%tarning %#%m",
                      "%#%l:%c %#%trror %#%m",
                    },
                    lintSource = "solhint",
                  },
                },
              },
            },
          })
        end,

        -- Lua Configuration
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
              },
            },
          })
        end,
      },
    })
    -- ✅ Fix misplaced keybindings (moved outside `handlers` and added `opts`)
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)

    -- ✅ Fix incorrect `dcmls` setup (was using `lsp.capabilities` instead of `capabilities`)
    local dartExcludedFolders = {
      vim.fn.expand("$HOME/AppData/Local/Pub/Cache"),
      vim.fn.expand("$HOME/.pub-cache"),
      vim.fn.expand("/opt/homebrew/"),
      vim.fn.expand("$HOME/tools/flutter/"),
    }

    lspconfig["dcmls"].setup({
      capabilities = capabilities,
      cmd = { "dcm", "start-server" },
      filetypes = { "dart", "yaml" },
      settings = {
        dart = { analysisExcludedFolders = dartExcludedFolders },
      },
    })

    -- Diagnostic UI Configuration
    vim.diagnostic.config({
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end,
}
