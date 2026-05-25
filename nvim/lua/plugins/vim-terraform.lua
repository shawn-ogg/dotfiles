return {
  {
    "hashivim/vim-terraform",
    ft = { "terraform", "tf", "hcl" },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "terraform",
        "hcl",
      },
    },
  },
}
