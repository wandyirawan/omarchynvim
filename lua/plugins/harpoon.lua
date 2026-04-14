-- Harpoon - Quick file navigation for your most important files
return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      local harpoon = require("harpoon")

      -- Setup harpoon with default config
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
          key = function()
            -- Use git branch as key for per-branch harpoon lists
            return vim.loop.cwd()
          end,
        },
      })

      -- Telescope integration (optional but nice)
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
              results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
          })
          :find()
      end

      -- Setup keymaps
      vim.keymap.set("n", "<leader>a", function()
        harpoon:list():add()
        vim.notify("󱡅 Added to Harpoon", vim.log.levels.INFO)
      end, { desc = "Harpoon: Add file" })

      vim.keymap.set("n", "<C-e>", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon: Toggle menu" })

      -- Navigate to files 1-4 (most used)
      vim.keymap.set("n", "<leader>1", function()
        harpoon:list():select(1)
      end, { desc = "Harpoon: File 1" })

      vim.keymap.set("n", "<leader>2", function()
        harpoon:list():select(2)
      end, { desc = "Harpoon: File 2" })

      vim.keymap.set("n", "<leader>3", function()
        harpoon:list():select(3)
      end, { desc = "Harpoon: File 3" })

      vim.keymap.set("n", "<leader>4", function()
        harpoon:list():select(4)
      end, { desc = "Harpoon: File 4" })

      vim.keymap.set("n", "<leader>5", function()
        harpoon:list():select(5)
      end, { desc = "Harpoon: File 5" })

      -- Alternative: Use Alt+number for even faster access (if your terminal supports it)
      vim.keymap.set("n", "<M-1>", function()
        harpoon:list():select(1)
      end, { desc = "Harpoon: File 1" })

      vim.keymap.set("n", "<M-2>", function()
        harpoon:list():select(2)
      end, { desc = "Harpoon: File 2" })

      vim.keymap.set("n", "<M-3>", function()
        harpoon:list():select(3)
      end, { desc = "Harpoon: File 3" })

      vim.keymap.set("n", "<M-4>", function()
        harpoon:list():select(4)
      end, { desc = "Harpoon: File 4" })

      vim.keymap.set("n", "<M-5>", function()
        harpoon:list():select(5)
      end, { desc = "Harpoon: File 5" })

      -- Navigate through harpoon list
      vim.keymap.set("n", "<C-S-P>", function()
        harpoon:list():prev()
      end, { desc = "Harpoon: Previous file" })

      vim.keymap.set("n", "<C-S-N>", function()
        harpoon:list():next()
      end, { desc = "Harpoon: Next file" })

      -- Telescope integration (optional)
      vim.keymap.set("n", "<leader>ht", function()
        toggle_telescope(harpoon:list())
      end, { desc = "Harpoon: Telescope" })

      -- Quick access via which-key menu (if you use which-key)
      vim.keymap.set("n", "<leader>h", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon Menu" })

      -- Additional utility keymaps
      vim.keymap.set("n", "<leader>hc", function()
        harpoon:list():clear()
        vim.notify("󱡅 Harpoon list cleared", vim.log.levels.INFO)
      end, { desc = "Harpoon: Clear all" })

      vim.keymap.set("n", "<leader>hr", function()
        harpoon:list():remove()
        vim.notify("󱡅 Removed from Harpoon", vim.log.levels.INFO)
      end, { desc = "Harpoon: Remove current file" })
    end,
    keys = {
      -- Preload keymaps for lazy loading
      { "<leader>a", desc = "Harpoon: Add file" },
      { "<C-e>", desc = "Harpoon: Toggle menu" },
      { "<leader>h", desc = "Harpoon Menu" },
      { "<leader>1", desc = "Harpoon: File 1" },
      { "<leader>2", desc = "Harpoon: File 2" },
      { "<leader>3", desc = "Harpoon: File 3" },
      { "<leader>4", desc = "Harpoon: File 4" },
      { "<leader>5", desc = "Harpoon: File 5" },
    },
  },

  -- Optional: Visual indicator in statusline for harpooned files
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      local harpoon_status = function()
        local harpoon = require("harpoon")
        local current_file = vim.api.nvim_buf_get_name(0)

        if current_file == "" then
          return ""
        end

        local list = harpoon:list()
        for i, item in ipairs(list.items) do
          if item.value == current_file or vim.fn.expand("%:p"):match(item.value) then
            return string.format("󱡅 [%d]", i)
          end
        end
        return ""
      end

      table.insert(opts.sections.lualine_c, {
        harpoon_status,
        color = { fg = "#7aa2f7", gui = "bold" },
      })
    end,
  },
}
