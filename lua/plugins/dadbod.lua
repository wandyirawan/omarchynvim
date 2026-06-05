return {
  -- ============================================================
  --  Dadbod — SQL Client in Neovim
  -- ============================================================
  --
  --  Dependencies (system): psql / mysql / sqlite3 CLI must be installed
  --  Connections via :DBUI or :DB <connection_string>
  --
  --  Quick start:
  --    :DBUI            → Open sidebar (connections + table explorer)
  --    :DB <url>        → Direct connect: postgresql://user:***@host/db
  --    :'<,'>DB         → Execute selected SQL (visual mode)
  --    :DB              → Execute query under cursor
  --    <leader>D        → Toggle dadbod UI sidebar
  --    <leader>dq       → Execute query (visual or whole buffer)
  -- ============================================================

  -- Core: database interaction engine
  {
    "tpope/vim-dadbod",
    cmd = { "DB" },
  },

  -- UI: sidebar with saved connections + table explorer
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod" },
      { "kristijanhusak/vim-dadbod-completion" },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      {
        "<leader>D",
        "<cmd>DBUIToggle<cr>",
        desc = "Toggle Dadbod UI",
      },
      {
        "<leader>dq",
        function()
          -- Execute selection if in visual mode, otherwise whole file
          local mode = vim.fn.mode()
          if mode == "v" or mode == "V" or mode == "\"\022\"" then
            vim.cmd("'<,'>DB")
          else
            vim.cmd("DB")
          end
        end,
        desc = "Execute SQL query",
      },
    },
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 35
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod_queries"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_tmp_query_location = vim.fn.stdpath("data") .. "/dadbod_tmp"
      vim.g.db_ui_auto_execute_table_helpers = true

      -- Auto-save named connections
      vim.g.db_ui_execute_on_save = false
    end,
  },

  -- Autocomplete: table names, columns, schemas
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
    config = function()
      -- Enable omni-completion for SQL files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.bo.omnifunc = "vim_dadbod_completion#omni"
        end,
      })

      -- Trigger completion with <C-Space> in insert mode
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { buffer = true, desc = "Dadbod SQL completion" })
        end,
      })
    end,
  },

  -- Custom connection presets (add your own here)
  {
    "tpope/vim-dadbod",
    keys = {
      {
        "<leader>dpl",
        function()
          vim.ui.input({ prompt = "PostgreSQL DB: " }, function(db)
            if db and #db > 0 then
              vim.ui.input({ prompt = "User: ", default = "postgres" }, function(user)
                if user then
                  vim.cmd("DB postgresql://" .. user .. "@localhost/" .. db)
                end
              end)
            end
          end)
        end,
        desc = "Connect PostgreSQL local",
      },
      {
        "<leader>dsl",
        function()
          vim.ui.input({ prompt = "SQLite file: " }, function(file)
            if file and #file > 0 then
              vim.cmd("DB sqlite:" .. file)
            end
          end)
        end,
        desc = "Connect SQLite local",
      },
    },
  },
}
