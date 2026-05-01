return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    ft = {
      "bash",
      "sh",
      "python",
      "yaml",
      "markdown",
      "lua",
      "json",
    },
    opts = {
      ensure_installed = {
        "bash",
        "python",
        "lua",
        "yaml",
        "json",
        "markdown",
        "markdown_inline",
      },
      highlight = {
        enable = true,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
