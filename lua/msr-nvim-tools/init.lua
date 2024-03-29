local M = {}

local bauhaus = require("msr-nvim-tools.bauhaus")
local snippets = require("msr-nvim-tools.snippets")

function M.setup()
  snippets.create()

  vim.api.nvim_create_user_command(
    "BauhausAnalyze", -- name
    bauhaus.analyze, -- command
    { -- opts
      nargs = 0,
      desc = "Bauhaus Single-File Analysis",
    }
  )
end

return M
