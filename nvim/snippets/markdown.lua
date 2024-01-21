local ls = require("luasnip")
local s = ls.s
local i = ls.i
local t = ls.t

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- --

local snippets = {}
local autosnippets = {}

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local map = vim.keymap.set
local opts = { noremap = true, silent = true, buffer = true }
local group = augroup("Markdown Snippets", { clear = true })

local function cs(trigger, nodes, keymap) --> cs stands for create snippet
  local snippet = s(trigger, nodes)
  table.insert(snippets, snippet)

  if keymap ~= nil then
    local pattern = "*.md"
    if type(keymap) == "table" then
      pattern = keymap[1]
      keymap = keymap[2]
    end
    autocmd("BufEnter", {
      pattern = pattern,
      group = group,
      callback = function()
        map({ "i" }, keymap, function()
          ls.snip_expand(snippet)
        end, opts)
      end,
    })
  end
end

local file_pattern = "*.md"

local function cs2(trigger, nodes, opts) --{{{
  local snippet = s(trigger, nodes)
  local target_table = snippets

  local pattern = file_pattern
  local keymaps = {}

  if opts ~= nil then
    -- check for custom pattern
    if opts.pattern then
      pattern = opts.pattern
    end

    -- if opts is a string
    if type(opts) == "string" then
      if opts == "auto" then
        target_table = autosnippets
      else
        table.insert(keymaps, { "i", opts })
      end
    end

    -- if opts is a table
    if opts ~= nil and type(opts) == "table" then
      for _, keymap in ipairs(opts) do
        if type(keymap) == "string" then
          table.insert(keymaps, { "i", keymap })
        else
          table.insert(keymaps, keymap)
        end
      end
    end

    -- set autocmd for each keymap
    if opts ~= "auto" then
      for _, keymap in ipairs(keymaps) do
        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = pattern,
          group = group,
          callback = function()
            vim.keymap.set(keymap[1], keymap[2], function()
              ls.snip_expand(snippet)
            end, { noremap = true, silent = true, buffer = true })
          end,
        })
      end
    end
  end

  table.insert(target_table, snippet) -- insert snippet into appropriate table
end --}}}

local function lp(package_name) -- Load Package Function
  package.loaded[package_name] = nil
  return require(package_name)
end

-- Utility Functions --

-- Start Refactoring --
cs("fFirst", {
  t({ "my first snippet", "", ">" }),
  i(1, "from"),
  c(2, { t("-->"), t("<--") }),
  i(3, "to"),
})
cs(
  "fSecond",
  fmt(
    [[
local {} = function({})
{}
end
]],
    {
      i(1, "func_name"),
      i(2, "args"),
      c(3, { t(""), t("-- TODO: implement func body"), i(1, "myArg") }),
    }
  )
)
cs2("fe-", { t("First auto snippet") }, "auto")

-- for auto trigger is hidden by default
cs2({ trig = "digit%d%d", regTrig = true, hidden = false }, { t("First auto snippet") }, "auto")
cs2({ trig = "word%d%d", regTrig = true, hidden = true }, { t("First auto snippet") }, "auto")
cs2({ trig = "test(%d)(%d)", regTrig = true }, {
  t("First auto snippet"),
  f(function(_, snip)
    return snip.captures[1] .. " and "
  end),
  f(function(_, snip)
    return snip.captures[2] .. " >> "
  end),
  i(1, " ONE "),
  f(function(arg, snip)
    return " ( " .. arg[1][1] .. " ) "
  end, 1),
  i(2, " TWO "),
  i(3, " THREE "),
  f(function(arg, snip)
    return " ( " .. arg[1][1]:upper() .. arg[2][1] .. " ) "
  end, { 2, 3 }),
}, "auto")

cs2({ trig = "www(%d)", regTrig = true, hidden = true }, {
  t("First auto snippet"),
  i(1, "ARG1"),
  rep(1),
}, "auto")

cs2({ trig = "www(%d)", regTrig = true, hidden = true }, {
  t("First auto snippet"),
  i(1, "ARG1"),
  rep(1),
}, "auto")

cs2( -- for([%w_]+) JS For Loop snippet{{{
  { trig = "for([%w_]+)", regTrig = true, hidden = true },
  fmt(
    [[
for (let {} = 0; {} < {}; {}++) {{
  {}
}}

{}
    ]],
    {
      d(1, function(_, snip) -- similar to func returns nodes
        return sn(1, i(1, snip.captures[1]))
      end),
      rep(1),
      c(2, { i(1, "num"), sn(1, { i(1, "arr"), t(".length") }) }),
      rep(1),
      i(3, "// TODO:"),
      i(4),
    }
  )
) --}}}
-- Start Refactoring --

return snippets, autosnippets
