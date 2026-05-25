-- ~/.config/nvim/lua/plugins/markdown-preview.lua

return {
  {
    "iamcco/markdown-preview.nvim",

    ft = { "markdown" },

    cmd = {
      "MarkdownPreviewToggle",
      "MarkdownPreview",
      "MarkdownPreviewStop",
    },

    build = "cd app && npm install",

    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_theme = "dark"
    end,

    keys = {
      {
        "<leader>mp",
        "<Cmd>MarkdownPreviewToggle<CR>",
        desc = "Markdown Preview",
      },
    },
  },
}
