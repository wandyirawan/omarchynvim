-- Disable inlay hints for ALL TypeScript LSP servers (vtsls, ts_ls, etc.)
return {
  -- Disable for vtsls (Vue TypeScript Language Server - LazyVim default)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              inlayHints = {
                parameterNames = { enabled = "none" },
                parameterTypes = { enabled = false },
                variableTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = false },
                functionLikeReturnTypes = { enabled = false },
                enumMemberValues = { enabled = false },
              },
            },
            javascript = {
              inlayHints = {
                parameterNames = { enabled = "none" },
                parameterTypes = { enabled = false },
                variableTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = false },
                functionLikeReturnTypes = { enabled = false },
                enumMemberValues = { enabled = false },
              },
            },
          },
        },
      },
    },
  },

  -- Force disable inlay hints on all buffers - IMMEDIATELY no delay
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Helper function to safely disable inlay hints
      local function disable_hints(bufnr)
        local ok = pcall(function()
          vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        end)
        if not ok then
          pcall(function()
            vim.lsp.inlay_hint.enable(bufnr, false)
          end)
        end
      end

      -- Create autocmd to disable inlay hints on all LSP attach - NO DELAY
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end
          -- Disable for any TypeScript/JavaScript related LSP - IMMEDIATELY
          if client.name:match("ts") or client.name:match("typescript") or client.name:match("vtsls") then
            disable_hints(args.buf)
          end
        end,
      })
    end,
  },

  -- Keymap to manually toggle
  {
    "neovim/nvim-lspconfig",
    keys = {
      {
        "<leader>uh",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          -- Check current state
          local is_enabled = false
          local ok, enabled = pcall(function()
            return vim.lsp.inlay_hint.is_enabled(bufnr)
          end)
          if ok then
            is_enabled = enabled
          end

          -- Toggle with new API
          local toggle_ok = pcall(function()
            vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = bufnr })
          end)
          if not toggle_ok then
            -- Fallback to old API
            pcall(function()
              vim.lsp.inlay_hint.enable(bufnr, not is_enabled)
            end)
          end

          vim.notify("Inlay hints " .. (not is_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
        end,
        desc = "Toggle Inlay Hints",
      },
    },
  },
}
