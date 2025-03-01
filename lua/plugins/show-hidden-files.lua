return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false, -- Show dotfiles like .git
          hide_gitignored = false, -- Show files ignored by .gitignore
          hide_hidden = false, -- Show hidden files and directories
          hide_by_name = {}, -- You can specify filenames to hide, leave empty to show all
          hide_by_pattern = {}, -- You can specify patterns to hide, leave empty to show all
          always_show = { "target" }, -- Always show specific directories like "target"
        },
      },
    },
  },
}
