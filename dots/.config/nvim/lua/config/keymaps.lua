-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "<leader>dr", function()
  vim.fn.jobstart({ "unvim-refresh", vim.fn.getcwd() }, {
    detach = true,
  })
end, { desc = "Unity: refresh domain" })
