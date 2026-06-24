return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false, -- load immediately
    -- priority = 1000, -- load before everything else
    opts = {
      flavour = "mocha",
      transparent_background = true,
      float = {
        transparent = true, -- enable transparent floating windows
        solid = false, -- use solid styling for floating windows, see |winborder|
      },
    },
  },
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    priority = 1000, -- load before everything else
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-nvim",
    },
  },
}