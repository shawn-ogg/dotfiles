return {
  {
    "folke/trouble.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<leader>fd",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics",
      },
    },
    opts = {},
    }
}
