return {
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
}
