return {
  {
    "preservim/vim-markdown",
    ft = "markdown",
    init = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_no_default_key_mappings = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_toml_frontmatter = 1
      vim.g.vim_markdown_json_frontmatter = 1

      -- Disable Copilot auto-trigger for prose
      vim.g.copilot_filetypes = {
        markdown = false,
      }
    end,
  },
}
