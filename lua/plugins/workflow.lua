-- Single window workflow improvements
return {
  -- Auto change directory to project root
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Auto cd to project root when opening file
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          local root_patterns = { ".git", "package.json", "go.mod", "Cargo.toml", "pyproject.toml", "bun.lockb" }
          local root_dir = vim.fs.dirname(vim.fs.find(root_patterns, { upward = true })[1])
          if root_dir then
            vim.cmd("silent! lcd " .. root_dir)
          end
        end,
      })
    end,
  },

  -- Better window navigation
  {
    "neovim/nvim-lspconfig",
    keys = {
      -- Window navigation
      { "<C-h>", "<C-w>h", desc = "Go to left window" },
      { "<C-j>", "<C-w>j", desc = "Go to down window" },
      { "<C-k>", "<C-w>k", desc = "Go to up window" },
      { "<C-l>", "<C-w>l", desc = "Go to right window" },

      -- Window splits
      { "<leader>-", "<C-w>s", desc = "Split window below" },
      { "<leader>|", "<C-w>v", desc = "Split window right" },
      { "<leader>wd", "<C-w>c", desc = "Close window" },

      -- Resize windows
      { "<C-Up>", "<cmd>resize +2<cr>", desc = "Increase window height" },
      { "<C-Down>", "<cmd>resize -2<cr>", desc = "Decrease window height" },
      { "<C-Left>", "<cmd>vertical resize -2<cr>", desc = "Decrease window width" },
      { "<C-Right>", "<cmd>vertical resize +2<cr>", desc = "Increase window width" },
    },
  },

  -- Better QuickFix and Location List
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "<leader>xl", "<cmd>lopen<cr>", desc = "Location List" },
      { "<leader>xq", "<cmd>copen<cr>", desc = "Quickfix List" },
      { "[q", vim.cmd.cprev, desc = "Previous quickfix" },
      { "]q", vim.cmd.cnext, desc = "Next quickfix" },
    },
  },

  -- Auto save on focus lost
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
        callback = function()
          if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
            vim.api.nvim_command("silent update")
          end
        end,
      })
    end,
  },

  -- Highlight yanked text
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
        end,
      })
    end,
  },

  -- Remember cursor position
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
          local mark = vim.api.nvim_buf_get_mark(0, '"')
          local lcount = vim.api.nvim_buf_line_count(0)
          if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
          end
        end,
      })
    end,
  },
}
