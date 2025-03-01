-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Key mapping to compile and run Java file
-- Compile and run C++ using F5
vim.api.nvim_set_keymap("n", "<leader>r", ":w<CR>:!g++ % -o %< && ./%<<CR>", { noremap = true, silent = true })

-- OR

-- Compile with g++ and run with F9
vim.api.nvim_set_keymap(
  "n",
  "<leader>s",
  ":w<CR>:!g++ -std=c++17 -Wall % -o %< && ./%<<CR>",
  { noremap = true, silent = true }
)
-- Compile and run C++ in a terminal buffer
vim.api.nvim_set_keymap("n", "<F5>", ":w<CR>:terminal g++ % -o %< && ./%<CR>", { noremap = true, silent = true })

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
vim.g.tmux_navigator_no_mappings = 1 -- Disable default mappings
vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", { silent = true })

-- DAP keybindings
map("n", "<F5>", ":lua require'dap'.continue()<CR>", opts)
map("n", "<F10>", ":lua require'dap'.step_over()<CR>", opts)
map("n", "<F11>", ":lua require'dap'.step_into()<CR>", opts)
map("n", "<F12>", ":lua require'dap'.step_out()<CR>", opts)

-- Toggle DAP UI (for visualization)
map("n", "<leader>du", ":lua require'dapui'.toggle()<CR>", opts)
