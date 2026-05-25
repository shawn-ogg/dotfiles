return {
	{
		"stevearc/conform.nvim",

		opts = {
			formatters_by_ft = {
				lua = { "stylua" },

				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },

				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				markdown = { "prettier" },
				yaml = { "prettier" },

        python = { "ruff_format" },
			},
		},

		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({
						async = true,
						lsp_fallback = true,
					})
				end,
				desc = "Format file",
			},
		},
	},
}
