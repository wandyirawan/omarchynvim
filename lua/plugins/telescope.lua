return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- Quick file switching
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find Word Under Cursor" },
    { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },

    -- Git telescope
    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
    { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
  },
  opts = {
    defaults = {
      -- Show hidden files (dotfiles like .env, .gitignore, etc)
      file_ignore_patterns = {
        "^.git/",
        "node_modules/",
        "%.jpg",
        "%.jpeg",
        "%.png",
        "%.svg",
        "%.otf",
        "%.ttf",
      },
    },
    pickers = {
      find_files = {
        -- Show hidden files in find_files
        hidden = true,
        -- Optionally respect .gitignore but still show .env files
        -- Set to false if you want to see files in .gitignore
        -- no_ignore = true,
      },
      live_grep = {
        -- Also search in hidden files
        additional_args = function()
          return { "--hidden" }
        end,
      },
    },
  },
}
