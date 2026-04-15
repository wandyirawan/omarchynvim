-- Noice configuration for cleaner hover types
return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      -- Preserve existing presets if any
      opts.presets = opts.presets or {}
      opts.lsp = opts.lsp or {}
      opts.lsp.hover = opts.lsp.hover or {}
      
      -- Add custom format filter for hover
      opts.lsp.hover.format = function(message, kind, client_name)
        -- Clean up verbose Elysia types
        if message and type(message) == "string" then
          -- Pattern to match Elysia<...> with long generic parameters
          local cleaned = message:gsub(
            "(Elysia<[^>]+)%s*{[^}]*decorator:[^}]*}",
            "%1{ ... }"
          )
          -- Clean up other verbose nested structures
          cleaned = cleaned:gsub("%s*{[^}]*store:[^}]*}", "{ ... }")
          cleaned = cleaned:gsub("%s*{[^}]*derive:[^}]*}", "{ ... }")
          cleaned = cleaned:gsub("%s*{[^}]*resolve:[^}]*}", "{ ... }")
          cleaned = cleaned:gsub("%s*{[^}]*typebox:[^}]*}", "{ ... }")
          cleaned = cleaned:gsub("%s*{[^}]*error:[^}]*}", "{ ... }")
          cleaned = cleaned:gsub("%s*{[^}]*schema:[^}]*}", "{ ... }")
          
          -- Limit line length for very long types
          local lines = {}
          for line in cleaned:gmatch("[^\r\n]+") do
            if #line > 120 then
              -- Truncate very long single lines
              line = line:sub(1, 120) .. " ..."
            end
            table.insert(lines, line)
          end
          
          return table.concat(lines, "\n")
        end
        return message
      end
      
      return opts
    end,
  },
}

-- Alternative: Disable noice hover and use native LSP
-- Uncomment below to use native LSP hover (more reliable filtering)
-- return {
--   {
--     "folke/noice.nvim",
--     opts = {
--       lsp = {
--         hover = {
--           enabled = false, -- Disable noice hover, use native
--         },
--       },
--     },
--   },
-- }
