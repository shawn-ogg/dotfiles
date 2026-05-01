return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    config = function()
      vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>")
      vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>")
      vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>")
      vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>")
    end,
  },
}
