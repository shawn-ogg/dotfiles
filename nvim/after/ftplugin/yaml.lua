-- Soft-wrap for long description blocks
vim.opt_local.wrap = true
vim.opt_local.linebreak = true

-- Folding on indent (collapse stories you're not editing)
vim.opt_local.foldmethod = "indent"
vim.opt_local.foldlevel = 1
vim.opt_local.foldnestmax = 2

-- :Story command — scaffold a new story entry
vim.api.nvim_buf_create_user_command(0, "Story", function()
  local template = {
    "  - title: \"\"",
    "    description: |",
    "      ",
    "    label: data-pipeline",
    "    acceptance_criteria: |",
    "      - ",
    "    owner: \"\"",
    "    pi: \"\"",
    "    sprint: \"\"",
    "    notes: |",
    "      ",
  }
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, template)
  -- Place cursor on the title line, inside the quotes
  vim.api.nvim_win_set_cursor(0, { row + 1, 13 })
  vim.cmd("startinsert")
end, { desc = "Insert a new story template" })
