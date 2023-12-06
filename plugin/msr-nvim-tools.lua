local tools = require("msr-nvim-tools")

vim.api.nvim_create_user_command(
  "BauhausAnalyze", -- name
  tools.bauhaus_analyze, -- command
  { -- opts
    nargs = 0,
    desc = "Bauhaus Single-File Analysis",
  }
)

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("cpp", {
  s("logger", {
    t("logger_.Log"),
    i(1),
    t({ "([&](::ara::log::LogStream& s) {", '\ts << "' }),
    i(0),
    t({ '";', "},", "Logger::LogLocation{__func__, __LINE__});" }),
  }),
})
