return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- We define the server manually here
        shader_ls = {
          -- CHANGE THIS PATH to where you extracted the server!
          cmd = { "dotnet", "/home/hamihu/.dotnet/tools/shader-ls", "--stdio" },
          filetypes = { "shader", "hlsl" },
          root_dir = require("lspconfig.util").root_pattern("Assets", ".git"),
        },
      },
    },
  },
}
