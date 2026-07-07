return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- We define the server manually here
        shader_ls = {
          cmd = { "/home/hamihu/.dotnet/tools/shader-ls", "--stdio" },
          cmd_env = { DOTNET_ROLL_FORWARD = "Major" },
          filetypes = { "shader", "hlsl" },
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(require("lspconfig.util").root_pattern("Assets", ".git")(fname))
          end,
        },
      },
    },
  },
}
