-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are automatically set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Helper function to safely disable inlay hints (handles API differences)
local function disable_inlay_hints(bufnr)
  local ok, err = pcall(function()
    -- Try new API first (Neovim 0.10+)
    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
  end)
  if not ok then
    -- Fallback to old API
    pcall(function()
      vim.lsp.inlay_hint.enable(bufnr, false)
    end)
  end
end

-- Disable inlay hints on LSP attach (too verbose for Elysia types)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      -- Disable inlay hints by default for TypeScript/JavaScript
      if client.name == "ts_ls" or client.name == "typescript-language-server" or client.name:match("typescript") or client.name:match("vtsls") then
        disable_inlay_hints(args.buf)
      end
    end
  end,
})

-- NUCLEAR OPTION: Completely disable all virtual text inlays for TypeScript
-- Disable IMMEDIATELY without delay (no flicker!)
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function(args)
    -- Disable immediately without delay
    disable_inlay_hints(args.buf)
  end,
})
