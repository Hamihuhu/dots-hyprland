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
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      -- your configuration comes here; leave empty for default settings
    },
  },
}
