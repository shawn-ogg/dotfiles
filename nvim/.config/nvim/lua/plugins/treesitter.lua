return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- The main branch is a rewrite for Neovim 0.12+. It only manages
      -- parsers and queries; highlighting is enabled through Neovim's API.
      require("nvim-treesitter").install({
        "bash",
        "python",
        "lua",
        "yaml",
        "json",
        "markdown",
        "markdown_inline",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "sh",
          "bash",
          "python",
          "lua",
          "yaml",
          "json",
          "markdown",
        },
        callback = function(args)
          -- Parser installation is asynchronous, so a parser may not be
          -- available yet on the first startup after this migration.
          pcall(vim.treesitter.start, args.buf)

          -- Preserve regex syntax highlighting alongside Tree-sitter for
          -- shell scripts, matching the old additional_vim_regex_highlighting setting.
          if vim.bo[args.buf].filetype == "sh" or vim.bo[args.buf].filetype == "bash" then
            vim.bo[args.buf].syntax = "ON"
          end
        end,
      })
    end,
  },
}
