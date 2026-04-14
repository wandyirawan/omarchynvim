-- Buffer navigation keymaps for single window workflow
return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      -- Navigate between buffers
      { "<S-h>", "<cmd>bprevious<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>bnext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>bprevious<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>bnext<cr>", desc = "Next Buffer" },

      -- Close current buffer
      { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete Buffer" },
      { "<leader>bD", "<cmd>bdelete!<cr>", desc = "Delete Buffer (Force)" },

      -- Close other buffers
      { "<leader>bo", "<cmd>%bd|e#|bd#<cr>", desc = "Close Other Buffers" },

      -- List all buffers (with Telescope)
      { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "List Buffers" },

      -- Switch to last buffer
      { "<leader><tab>", "<cmd>b#<cr>", desc = "Switch to Last Buffer" },
    },
  },

  -- Better buffer deletion using LazyVim's built-in bufremove
  {
    "neovim/nvim-lspconfig",
    keys = {
      {
        "<leader>bd",
        function()
          LazyVim.ui.bufremove()
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>bD",
        function()
          vim.cmd("bd!")
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },
}
