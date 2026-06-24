return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    lazygit = {
      config = {
        gui = {
          mainPanelSplitMode = vertical,
          screenMode = half,
          showNumstatInFilesView = true,
          switchTabsWithPanelJumpKeys = true,
        },
      },
    },
  },
}
