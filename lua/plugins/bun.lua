-- Bun.js specific configuration and LSP setup
return {
  -- Main Bun LSP configuration
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require("lspconfig.util")
      local lspconfig = require("lspconfig")

      -- Detect Bun project by looking for bun.lock, bun.lockb, or bunfig.toml
      local function is_bun_project(fname)
        return util.root_pattern("bun.lock", "bun.lockb", "bunfig.toml")(fname) ~= nil
      end

      -- Check if Bun types are installed (supports both bun-types and @types/bun)
      local function has_bun_types(root_dir)
        local package_json = root_dir .. "/package.json"
        -- Check for both bun-types and @types/bun
        local bun_types_1 = root_dir .. "/node_modules/bun-types"
        local bun_types_2 = root_dir .. "/node_modules/@types/bun"

        if vim.fn.isdirectory(bun_types_1) == 1 or vim.fn.isdirectory(bun_types_2) == 1 then
          return true
        end

        -- Check package.json for both package names
        if vim.fn.filereadable(package_json) == 1 then
          local content = table.concat(vim.fn.readfile(package_json), "\n")
          return content:match("bun%-types") or content:match("@types/bun")
        end

        return false
      end

      -- Autocmd to detect Bun projects and suggest types installation
      vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
        pattern = { "*.ts", "*.js", "*.tsx", "*.jsx" },
        callback = function(args)
          local bufnr = args.buf
          local fname = vim.api.nvim_buf_get_name(bufnr)

          if is_bun_project(fname) then
            local root_dir = util.root_pattern("bun.lock", "bun.lockb", "bunfig.toml", "package.json")(fname)
            if root_dir and not has_bun_types(root_dir) then
              vim.notify(
                "📦 Bun project detected!\n"
                  .. "Run 'bun add -d bun-types' or 'bun add -d @types/bun' for full LSP support",
                vim.log.levels.INFO
              )
            end
          end
        end,
        once = true,
      })

      -- Configure TypeScript server for Bun
      opts.servers = opts.servers or {}
      opts.servers.ts_ls = vim.tbl_deep_extend("force", opts.servers.ts_ls or {}, {
        root_dir = function(fname)
          -- Prioritize Bun project indicators (both bun.lock and bun.lockb)
          return util.root_pattern("bun.lock", "bun.lockb", "bunfig.toml")(fname)
            or util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")(fname)
            or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              -- DISABLED: Variable type hints (too verbose for Elysia types)
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = true,
              -- DISABLED: Return type hints (too verbose for Elysia chain methods)
              includeInlayFunctionLikeReturnTypeHints = false,
              includeInlayEnumMemberValueHints = true,
            },
            preferences = {
              importModuleSpecifier = "relative",
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              -- DISABLED: Variable type hints (too verbose for Elysia types)
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = true,
              -- DISABLED: Return type hints (too verbose for Elysia chain methods)
              includeInlayFunctionLikeReturnTypeHints = false,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- Add bun-specific file type detection
      vim.filetype.add({
        pattern = {
          [".*/bun%.lockb"] = "text",
          [".*/bunfig%.toml"] = "toml",
        },
      })

      -- Set global variable to indicate Bun project
      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        pattern = "*.ts,*.js,*.tsx,*.jsx",
        callback = function()
          local fname = vim.api.nvim_buf_get_name(0)
          if is_bun_project(fname) then
            vim.g.is_bun_project = true
            vim.b.is_bun_project = true
          end
        end,
      })
    end,
  },

  -- Bun keymaps for running files and tests
  -- Using Snacks.terminal for async execution with toggle capability
  {
    "neovim/nvim-lspconfig",
    keys = {
      -- Run current file with Bun (async terminal that can be toggled)
      {
        "<leader>rb",
        function()
          local file = vim.fn.expand("%")
          Snacks.terminal("bun run " .. vim.fn.shellescape(file), {
            interactive = true,
            auto_close = false,
          })
        end,
        desc = "Run file with Bun",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      },
      -- Run current file with Bun --watch (for dev mode)
      {
        "<leader>rB",
        function()
          local file = vim.fn.expand("%")
          Snacks.terminal("bun run --watch " .. vim.fn.shellescape(file), {
            interactive = true,
            auto_close = false,
          })
        end,
        desc = "Run file with Bun --watch",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      },
      -- Run Bun tests (async terminal)
      {
        "<leader>rt",
        function()
          Snacks.terminal("bun test", {
            interactive = true,
            auto_close = false,
          })
        end,
        desc = "Run Bun tests",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      },
      -- Run Bun tests with watch mode
      {
        "<leader>rT",
        function()
          Snacks.terminal("bun test --watch", {
            interactive = true,
            auto_close = false,
          })
        end,
        desc = "Run Bun tests --watch",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      },
      -- Install dependencies with Bun (async terminal)
      {
        "<leader>ri",
        function()
          Snacks.terminal("bun install", {
            interactive = true,
            auto_close = false,
          })
        end,
        desc = "Bun install",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      },
      -- Add bun-types (async terminal)
      {
        "<leader>rbt",
        function()
          Snacks.terminal("bun add -d bun-types", {
            interactive = true,
            auto_close = false,
          })
        end,
        desc = "Add Bun types",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      },
      -- Add Elysia (async terminal)
      {
        "<leader>re",
        function()
          Snacks.terminal("bun add elysia", {
            interactive = true,
            auto_close = false,
          })
        end,
        desc = "Add Elysia",
        ft = { "typescript", "javascript" },
      },
      -- Kill/Toggle terminal (useful to stop running Bun processes)
      {
        "<leader>rk",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Toggle terminal",
      },
    },
  },

  -- Neotest integration for Bun tests
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "bun test",
          jestConfigFile = "custom.jest.config.ts",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },

  -- Null-ls / none-ls for Bun-specific linting and formatting
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local null_ls = require("null-ls")
      opts.sources = opts.sources or {}

      -- Add Bun-aware sources
      table.insert(opts.sources, null_ls.builtins.formatting.prettier.with({
        condition = function(utils)
          return utils.root_has_file({ "bun.lockb", "bunfig.toml", "package.json" })
        end,
      }))
    end,
  },

  -- Conform formatter configuration for Bun projects
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
      },
      formatters = {
        prettier = {
          command = function()
            -- Use Bun to run prettier if available
            if vim.fn.executable("bunx") == 1 then
              return "bunx"
            end
            return "prettier"
          end,
          args = function()
            if vim.fn.executable("bunx") == 1 then
              return { "prettier", "--stdin-filepath", "$FILENAME" }
            end
            return { "--stdin-filepath", "$FILENAME" }
          end,
        },
      },
    },
  },

  -- Treesitter Bun-specific configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "toml", -- for bunfig.toml
      })
    end,
  },
}
