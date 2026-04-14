return {
  -- Import LazyVim language extras for automatic LSP setup

  -- TypeScript/JavaScript support
  -- Includes: typescript-language-server, eslint, prettier

  -- Python support
  -- Includes: pyright/basedpyright, ruff (linter & formatter)

  -- Go support
  -- Includes: gopls, gofmt, goimports

  -- Rust support
  -- Includes: rust-analyzer, rustfmt

  -- Zig support
  -- Includes: zls (zig language server)

  -- Elixir support
  -- Includes: elixir-ls (language server)

  -- Additional LSP server configurations
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- TypeScript/JavaScript optimized for Bun (supports both bun.lock and bun.lockb)
        ts_ls = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            -- Prioritize Bun project indicators
            return util.root_pattern("bun.lock", "bun.lockb", "bunfig.toml")(fname)
              or util.root_pattern("package.json", "tsconfig.json", "jsconfig.json")(fname)
              or util.find_git_ancestor(fname)
          end,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              preferences = {
                importModuleSpecifier = "relative",
                includePackageJsonAutoImports = "on",
              },
              -- Bun-specific: Allow Bun globals
              suggest = {
                autoImports = true,
                completeFunctionCalls = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },

        -- ESLint for Bun projects
        eslint = {
          settings = {
            workingDirectories = { mode = "auto" },
            -- Support Bun projects
            nodePath = "",
          },
        },

        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
      },
    },
  },

  -- Mason tool installer - ensure all necessary tools are installed
  -- Note: mason.nvim moved to mason-org, ensure_installed now handled by mason-tool-installer
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  -- Mason tool installer for formatters, linters, and DAPs
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    cmd = {
      "MasonToolsInstall",
      "MasonToolsUpdate",
      "MasonToolsClean",
    },
    opts = {
      ensure_installed = {
        -- Go tools
        "gopls",
        "gofumpt",
        "goimports",
        "gomodifytags",
        "impl",
        "delve", -- Go debugger

        -- Rust tools
        "rust-analyzer",
        "rustfmt",

        -- Zig tools
        "zls",

        -- Elixir tools
        "elixir-ls",

        -- Python tools
        "pyright",
        "ruff",
        "black",
        "debugpy", -- Python debugger

        -- JavaScript/TypeScript tools
        "typescript-language-server",
        "eslint-lsp",
        "prettier",
        "js-debug-adapter",

        -- Additional formatters/linters
        "stylua", -- Lua formatter
        "shellcheck",
        "shfmt",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- Treesitter parsers for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "go",
        "gomod",
        "gowork",
        "gosum",
        "rust",
        "zig",
        "elixir",
        "heex", -- for Phoenix templates
        "eex", -- for Embedded Elixir
        "python",
        "javascript",
        "typescript",
        "tsx",
        "jsdoc",
        "toml", -- for bunfig.toml
        "yaml",
        "json",
        "jsonc",
      })
    end,
  },

  -- Bun-specific configurations and file type detection
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Add autocmd to recognize bun.lockb files as binary
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "bun.lockb",
        callback = function()
          vim.bo.filetype = "text"
          vim.bo.binary = true
        end,
      })

      -- bun.lock (text-based lockfile) - don't set binary
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "bun.lock",
        callback = function()
          vim.bo.filetype = "text"
          vim.bo.readonly = true
        end,
      })

      -- Add autocmd to recognize bunfig.toml
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "bunfig.toml",
        callback = function()
          vim.bo.filetype = "toml"
        end,
      })

      -- TypeScript/Bun project tsconfig.json helper
      local function check_tsconfig()
        local root = vim.fn.getcwd()
        local tsconfig = root .. "/tsconfig.json"

        if vim.fn.filereadable(tsconfig) == 1 then
          local content = table.concat(vim.fn.readfile(tsconfig), "\n")
          -- Check if Bun types are included (check for bun-types, @types/bun, or bun in types)
          local has_bun_types_in_config = content:match("bun")
          local has_bun_types_installed = vim.fn.isdirectory(root .. "/node_modules/bun-types") == 1
            or vim.fn.isdirectory(root .. "/node_modules/@types/bun") == 1

          if not has_bun_types_in_config and has_bun_types_installed then
            vim.notify(
              "⚠️  tsconfig.json detected but doesn't include Bun types.\n"
                .. "Add 'bun-types' or 'bun' to compilerOptions.types for better LSP support.",
              vim.log.levels.WARN
            )
          end
        end
      end

      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        pattern = "*.ts,*.tsx,*.js,*.jsx",
        callback = function()
          if vim.g.checked_tsconfig then
            return
          end
          vim.g.checked_tsconfig = true
          check_tsconfig()
        end,
        once = true,
      })
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
    },
  },

  -- Additional Bun/Elysia helpers
  {
    "nvim-lua/plenary.nvim",
    keys = {
      -- Quick Bun type generation
      {
        "<leader>rT",
        function()
          local templates = {
            ["tsconfig.json"] = vim.json.encode({
              compilerOptions = {
                lib = { "ESNext" },
                module = "esnext",
                target = "esnext",
                moduleResolution = "bundler",
                moduleDetection = "force",
                allowImportingTsExtensions = true,
                noEmit = true,
                composite = true,
                strict = true,
                downlevelIteration = true,
                skipLibCheck = true,
                jsx = "react-jsx",
                allowSyntheticDefaultImports = true,
                forceConsistentCasingInFileNames = true,
                allowJs = true,
                types = { "bun" },
              },
              include = { "src/**/*", "tests/**/*" },
            }),
          }

          for filename, content in pairs(templates) do
            if vim.fn.filereadable(filename) == 0 then
              vim.fn.writefile(vim.split(content, "\n"), filename)
              vim.notify("✅ Created " .. filename .. " with Bun configuration", vim.log.levels.INFO)
            end
          end
        end,
        desc = "Create Bun tsconfig.json",
      },
    },
  },
}
