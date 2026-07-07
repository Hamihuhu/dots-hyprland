-- Disable roslyn_ls (nvim-lspconfig) since seblyng/roslyn.nvim handles C# via its own "roslyn" server
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        roslyn_ls = { enabled = false },
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {},
  },
}
