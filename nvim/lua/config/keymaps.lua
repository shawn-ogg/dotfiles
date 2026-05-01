local map = vim.keymap.set

vim.g.mapleader = " "

map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")

map("n", "gd", vim.lsp.buf.definition)
map("n", "gr", vim.lsp.buf.references)
map("n", "K", vim.lsp.buf.hover)

-- preserve clipboard on delete/change
vim.keymap.set({ "n", "v" }, "d", '"_d')
vim.keymap.set({ "n", "v" }, "c", '"_c')

-- leader versions still yank normally
vim.keymap.set({ "n", "v" }, "<leader>d", "d")
vim.keymap.set({ "n", "v" }, "<leader>c", "c")
