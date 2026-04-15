-- Alternative: Use pretty_hover for cleaner type display
return {
  {
    "Fildo7525/pretty_hover",
    event = "LspAttach",
    opts = {
      max_width = 80,
      max_height = 20,
      -- Custom handlers for specific patterns
      line = {
        -- Match and shorten Elysia types
        { pattern = "(Elysia<[^>]+)%s*{%s*decorator:.*}", replace = "%1{ ... }" },
      },
    },
  },
}
