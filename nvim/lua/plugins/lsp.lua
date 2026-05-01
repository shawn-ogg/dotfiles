return {
  {
    "neovim/nvim-lspconfig",

    ft = {
      "python",
      "sh",
      "bash",
      "yaml",
      "markdown",
      "lua",
    },

    config = function()
      vim.lsp.log.set_level("OFF")

      local file = vim.fn.expand("%:p")

      if file:match("/tmp/") then
        return
      end

      vim.lsp.config("pyright", {})
      vim.lsp.enable("pyright")

      vim.lsp.config("bashls", {})
      vim.lsp.enable("bashls")

      vim.lsp.config("marksman", {})
      vim.lsp.enable("marksman")

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      vim.lsp.enable("lua_ls")

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            },
          },
        },
      })

      vim.lsp.enable("yamlls")
    end,
  },
}
