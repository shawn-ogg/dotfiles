local map = vim.keymap.set

vim.g.mapleader = " "

map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

-- map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
-- map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
-- map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")

map("n", "gd", vim.lsp.buf.definition)
map("n", "gr", vim.lsp.buf.references)
map("n", "K", vim.lsp.buf.hover)

-- -- preserve clipboard on delete/change
-- vim.keymap.set({ "n", "v" }, "d", '"_d')
-- vim.keymap.set({ "n", "v" }, "c", '"_c')
--
-- -- leader versions still yank normally
-- vim.keymap.set({ "n", "v" }, "<leader>d", "d")
-- vim.keymap.set({ "n", "v" }, "<leader>c", "c")


-- open urls (on mac with open)
local open = function(url)
  vim.fn.jobstart({ "/usr/bin/open", url }, {
    detach = true,
  })
end

vim.keymap.set("n", "gx", function()
  local line = vim.api.nvim_get_current_line()
  local urls = {}

  for url in line:gmatch("https?://[^%s%)]+") do
    urls[#urls + 1] = url
  end

  if #urls == 1 then
    open(urls[1])
  elseif #urls > 1 then
    vim.ui.select(urls, {
     prompt = "Open URL",
    }, open)
  end
end)

-- Diagnostics -------------------------------------------------------------

vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {
  desc = "Next diagnostic",
})

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {
  desc = "Previous diagnostic",
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {
  desc = "Diagnostic details",
})

-- Telescope ---------------------------------------------------------------

vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>fr", function()
  require("telescope.builtin").oldfiles()
end, { desc = "Recent files" })

-- code actions -------------------------------------------------------------
-- Use <leader>ca for code actions
-- Use K to show documentation in a floating window
-- Use gd to jump to definition
-- Use gr to list references
-- Use <leader>rn to rename symbol
-- Use <leader>f to format code
-- Use <leader>e to show diagnostics in a floating window
-- Use [d and ]d to navigate diagnostics
-- Use <leader>dd to list diagnostics in a Telescope window
-- Use <leader>ff to find files
-- Use <leader>fg to live grep
-- Use <leader>fb to list buffers
-- Use <leader>fr to list recent files
-- Use gx to open URLs under the cursor
-- Use <leader>w to save files
-- Use <leader>q to quit
-- Use <leader>h to show help
-- Use <leader>v to open vertical split
-- Use <leader>s to open horizontal split
-- Use <leader>t to open a new tab
-- Use <leader>c to copy to clipboard
-- Use <leader>p to paste from clipboard
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
  desc = "Code action",
})


vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" then
      vim.fn.setreg("+", vim.fn.getreg('"'))
    end
  end,
})
