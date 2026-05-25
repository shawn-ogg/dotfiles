return {
	{
		"zbirenbaum/copilot.lua",

		event = "InsertEnter",

		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,

				keymap = {
					accept = "<M-y>",
					-- accept_word = "<M-w>",
					-- accept_line = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},

			panel = {
				enabled = false,
			},
		},
	},

	{
		"CopilotC-Nvim/CopilotChat.nvim",

		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},

		build = "make tiktoken",

		opts = {
			model = "gpt-4.1",
		},

		keys = {
			{
				"<leader>cc",
				function()
					require("CopilotChat").toggle()
				end,
				desc = "Copilot Chat",
			},
		},

		config = function(_, opts)
			local chat = require("CopilotChat")

			chat.setup(opts)

			-- Start typing immediately in chat
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.cmd("startinsert")
				end,
			})

			-- Submit from insert mode
			vim.keymap.set("i", "<C-s>", function()
				vim.cmd("CopilotChatSubmit")
			end)

			-- Submit from normal mode
			vim.keymap.set("n", "<CR>", function()
				vim.cmd("CopilotChatSubmit")
			end)
		end,
	},
}
