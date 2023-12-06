local M = {}

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep

function M.create()
  ls.add_snippets("cpp", {
    s("lg", {
      t("logger_.Log"),
      i(1),
      t({ "([&](::ara::log::LogStream& s) {", '\ts << "' }),
      i(0),
      t({ '";', "},", "Logger::LogLocation{__func__, __LINE__});" }),
    }),
    s("dx", {
      t({ "/*!", " * \\brief " }),
      i(1),
      t({ "", " */" }),
    }),
    s("sptr", {
      t("std::shared_ptr<"),
      i(1),
      t("> "),
      i(2),
      t("{std::make_shared<"),
      rep(1),
      t(">("),
      i(3),
      t(")};"),
    }),
    s("uptr", {
      t("std::unique_ptr<"),
      i(1),
      t("> "),
      i(2),
      t("{std::make_unique<"),
      rep(1),
      t(">("),
      i(3),
      t(")};"),
    }),
  })
end

return M
