-- ~/.config/nvim/lua/plugins/venn.lua

return {
  {
    "jbyuki/venn.nvim",

    ft = { "markdown" },

    config = function()
      local map = vim.keymap.set

      ----------------------------------------------------------------
      -- ENABLE VENN DRAWING MODE
      ----------------------------------------------------------------

      local function toggle_venn()
        local venn_enabled = vim.b.venn_enabled

        if venn_enabled then
          vim.cmd("setlocal virtualedit=")

          vim.keymap.del("n", "J", { buffer = true })
          vim.keymap.del("n", "K", { buffer = true })
          vim.keymap.del("n", "L", { buffer = true })
          vim.keymap.del("n", "H", { buffer = true })
          vim.keymap.del("v", "f", { buffer = true })

          vim.b.venn_enabled = nil

          print("Venn OFF")
        else
          vim.cmd("setlocal virtualedit=all")

          map("n", "J", "<C-v>j:VBox<CR>", { buffer = true })
          map("n", "K", "<C-v>k:VBox<CR>", { buffer = true })
          map("n", "L", "<C-v>l:VBox<CR>", { buffer = true })
          map("n", "H", "<C-v>h:VBox<CR>", { buffer = true })

          map("v", "f", ":VBox<CR>", { buffer = true })

          vim.b.venn_enabled = true

          print("Venn ON")
        end
      end

      ----------------------------------------------------------------
      -- TOGGLE
      ----------------------------------------------------------------

      map("n", "<leader>vv", toggle_venn, {
        desc = "Toggle Venn",
      })
    end,
  },
}
