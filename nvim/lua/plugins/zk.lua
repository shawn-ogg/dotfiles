-- ~/.config/nvim/lua/plugins/zk.lua

local function zk_new(dir)
	vim.ui.input({
		prompt = "Note title: ",
	}, function(input)
		if not input or input == "" then
			return
		end

		local cmd = string.format("ZkNew { title = %q, dir = %q }", input, dir)

		vim.cmd(cmd)
	end)
end

return {
	{
		"zk-org/zk-nvim",

		lazy = true,

		cmd = {
			"ZkNew",
			"ZkNotes",
			"ZkBacklinks",
			"ZkLinks",
			"ZkTags",
			"ZkInsertLink",
			"ZkFollowLink",
		},

		keys = {
			----------------------------------------------------------------
			-- NOTES
			----------------------------------------------------------------

			{
				"<leader>zn",
				function()
					zk_new(".")
				end,
				desc = "ZK New Note",
			},

			{
				"<leader>zf",
				"<Cmd>ZkNotes<CR>",
				desc = "ZK Find Notes",
			},

			{
				"<leader>zb",
				"<Cmd>ZkBacklinks<CR>",
				desc = "ZK Backlinks",
			},

			{
				"<leader>zl",
				"<Cmd>ZkLinks<CR>",
				desc = "ZK Links",
			},

			{
				"<leader>zt",
				"<Cmd>ZkTags<CR>",
				desc = "ZK Tags",
			},

			{
				"<leader>zi",
				"<Cmd>ZkInsertLink<CR>",
				desc = "ZK Insert Link",
			},

			----------------------------------------------------------------
			-- GROUPS
			----------------------------------------------------------------

			{
				"<leader>zw",
				function()
					zk_new("work")
				end,
				desc = "ZK Work Note",
			},

			{
				"<leader>zp",
				function()
					zk_new("projects")
				end,
				desc = "ZK Project Note",
			},

			{
				"<leader>zs",
				function()
					zk_new("scratch")
				end,
				desc = "ZK Scratch Note",
			},

			----------------------------------------------------------------
			-- DAILY
			----------------------------------------------------------------

			{
				"<leader>zd",
				function()
					require("zk.commands").get("ZkNew")({
						dir = "daily",
						title = os.date("%Y-%m-%d"),
					})
				end,
				desc = "ZK Daily Note",
			},
		},

		dependencies = {
			"nvim-telescope/telescope.nvim",
		},

		config = function()
			vim.env.ZK_NOTEBOOK_DIR = vim.fn.expand("~/notes")

			require("zk").setup({
				picker = "telescope",

				lsp = {
					config = {
						cmd = { "zk", "lsp" },
						name = "zk",
					},

					auto_attach = {
						enabled = true,
						filetypes = { "markdown" },
					},
				},
			})

			local map = vim.keymap.set

			----------------------------------------------------------------
			-- MARKDOWN SETTINGS
			----------------------------------------------------------------

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",

				callback = function(event)
					local opts = { buffer = event.buf }

					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
					vim.opt_local.spell = true
					vim.opt_local.conceallevel = 1

					----------------------------------------------------------------
					-- FOLLOW WIKI LINKS
					----------------------------------------------------------------

					map(
						"n",
						"<CR>",
						"<Cmd>ZkFollowLink<CR>",
						vim.tbl_extend("force", opts, {
							desc = "Follow Wiki Link",
						})
					)
				end,
			})

			----------------------------------------------------------------
			-- CURSOR ON UNTITLED
			----------------------------------------------------------------

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*.md",

				callback = function()
					vim.schedule(function()
						local line = vim.api.nvim_get_current_line()

						local col = line:find("Untitled")

						if col then
							vim.api.nvim_win_set_cursor(0, { 1, col - 1 })
						end
					end)
				end,
			})
		end,
	},
}
