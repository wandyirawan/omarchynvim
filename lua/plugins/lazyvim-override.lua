-- Override LazyVim defaults to disable inlay hints
-- This prevents LazyVim from auto-enabling inlay hints
return {
  -- Override LazyVim's default inlay hint settings
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Ensure inlay hints are disabled by default for all LSP servers
      opts.inlay_hints = opts.inlay_hints or {}
      opts.inlay_hints.enabled = false

      -- Also disable for specific servers
      if opts.servers then
        for _, server in pairs(opts.servers) do
          if server.settings then
            -- Try to disable inlay hints in server settings
            if server.settings.typescript and server.settings.typescript.inlayHints then
              server.settings.typescript.inlayHints.includeInlayVariableTypeHints = false
              server.settings.typescript.inlayHints.includeInlayFunctionLikeReturnTypeHints = false
            end
            if server.settings.javascript and server.settings.javascript.inlayHints then
              server.settings.javascript.inlayHints.includeInlayVariableTypeHints = false
              server.settings.javascript.inlayHints.includeInlayFunctionLikeReturnTypeHints = false
            end
          end
        end
      end

      return opts
    end,
  },
}
