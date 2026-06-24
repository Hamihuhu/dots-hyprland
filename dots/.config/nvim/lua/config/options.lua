-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.scrolloff = 15
vim.opt.showcmd = true
vim.filetype.add({
  extension = {
    shader = "shader",
    hlsl = "hlsl",
  },
})
