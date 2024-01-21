-- local utils = require("astronvim.utils")
-- local ui = require("astronvim.utils.ui")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

local function close_floating()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end

local function notify(msg, type, opts)
  vim.schedule(function()
    vim.notify(msg, type, opts)
  end)
end

local function toggle_term_cmd(opts)
  local terms = {}
  -- if a command string is provided, create a basic table for Terminal:new() options
  if type(opts) == "string" then
    opts = { cmd = opts, hidden = true }
  end
  local num = vim.v.count > 0 and vim.v.count or 1
  -- if terminal doesn't exist yet, create it
  if not terms[opts.cmd] then
    terms[opts.cmd] = {}
  end
  if not terms[opts.cmd][num] then
    if not opts.count then
      opts.count = vim.tbl_count(terms) * 100 + num
    end
    if not opts.on_exit then
      opts.on_exit = function()
        terms[opts.cmd][num] = nil
      end
    end
    terms[opts.cmd][num] = require("toggleterm.terminal").Terminal:new(opts)
  end
  -- toggle the terminal
  terms[opts.cmd][num]:toggle()
end

local function system_open(path)
  -- TODO: REMOVE WHEN DROPPING NEOVIM <0.10
  if vim.ui.open then
    return vim.ui.open(path)
  end
  local cmd
  if vim.fn.has("win32") == 1 and vim.fn.executable("explorer") == 1 then
    cmd = { "cmd.exe", "/K", "explorer" }
  elseif vim.fn.has("unix") == 1 and vim.fn.executable("xdg-open") == 1 then
    cmd = { "xdg-open" }
  elseif (vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1) and vim.fn.executable("open") == 1 then
    cmd = { "open" }
  end
  if not cmd then
    notify("Available system opening tool not found!", vim.log.levels.ERROR)
  end
  vim.fn.jobstart(vim.fn.extend(cmd, { path or vim.fn.expand("<cfile>") }), { detach = true })
end

local function is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
  return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end
local icons = require("fg.icons")

-- local sections = {
--   f = { desc = icons.astro.Search .. " Find" },
--   p = { desc = icons.astro.Package .. "Packages" },
--   l = { desc = icons.astro.ActiveLSP .. "LSP" },
--   u = { desc = icons.astro.Window .. "UI" },
--   b = { desc = icons.astro.Tab .. "Buffers" },
--   bs = { desc = icons.astro.Sort .. "Sort Buffers" },
--   d = { desc = icons.astro.Debugger .. "Debugger" },
--   g = { desc = icons.astro.Git .. "Git" },
--   S = { desc = icons.astro.Session .. "Session" },
--   t = { desc = icons.astro.Terminal .. "Terminal" },
-- }
--
-- local maps = { i = {}, n = {}, v = {}, t = {} }
--
-- maps.n["<leader><leader>w"] = { "<cmd>w<cr>", desc = "Save File" }
-- maps.n["<leader><leader>b"] = {
--   function()
--     require("mini.bufremove").delete(0, false)
--   end,
--   desc = "Save File",
-- }
-- maps.n["<leader>q"] = { "<cmd>confirm q<cr>", desc = "Quit" }
-- maps.n["<leader>n"] = { "<cmd>enew<cr>", desc = "New File" }
-- maps.n["-"] = { "<cmd>Oil<cmd>", desc = "Open parent directory" }
-- maps.n["gx"] = { system_open, desc = "Open the file under cursor with system app" }
-- maps.n["<C-s>"] = { "<cmd>w!<cr>", desc = "Force write" }
-- maps.n["<C-q>"] = { "<cmd>q!<cr>", desc = "Force quit" }
-- maps.n["<leader>bs"] = sections.bs

map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
map("n", "<leader><leader>w", "<cmd>w<cr><esc>", { desc = "Save File", remap = true })
map("n", "<leader><leader>k", "<cmd>WhichKey <cr>", { desc = "Key Bindings", remap = true })
map("n", "<leader><leader>b", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Save File", remap = true })

map("n", "<leader>cs", "<cmd>w<cr><esc>", { desc = "Save File", remap = true })
map("n", "<leader>k", "<cmd>WhichKey <cr>", { desc = "Key Bindings", remap = true })
map("n", "<leader>cc", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Save File", remap = true })
-- General
map("i", "jk", "<ESC>", { desc = "Exit insert mode" }) -- does not work
map("n", "x", '"_x', { desc = "Delete single char without copying into register" })
map("n", "<C-d>", "<C-d>zz", { desc = "scroll down and then center the cursorline" })
map("n", "<C-u>", "<C-u>zz", { desc = "scroll up and then center the cursorline" })
map("x", "<leader>p", [["_dP]], { desc = "Paste on highlighted without copying hightlighted text" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank into system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank into system clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Find out what does this do" })
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor in place" })

map("n", "<esc>", function()
  close_floating()
  vim.cmd(":noh")
end, { silent = true, desc = "Remove Search Highlighting, Dismiss Popups" })
-------------------------------------------------------------------------------

map("n", "<leader>z", function()
  if vim.g.zen_mode_active then
    require("zen-mode").toggle()
    vim.g.zen_mode_active = false
  else
    require("zen-mode").toggle()
    vim.g.zen_mode_active = true
  end
end, { desc = "Zen Mode Toggle" })

-- MUST HAVE
map("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "Automaton fun" })

-- -- Comment
-- if is_available("Comment.nvim") then
--   maps.n["<leader>/"] = {
--     function()
--       require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1)
--     end,
--     desc = "Comment line",
--   }
--   maps.v["<leader>/"] =
--     { "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", desc = "Toggle comment line" }
-- end

-- Smart Splits
-- if is_available("smart-splits.nvim") then
--   maps.n["<C-h>"] = {
--     function()
--       require("smart-splits").move_cursor_left()
--     end,
--     desc = "Move to left split",
--   }
--   maps.n["<C-j>"] = {
--     function()
--       require("smart-splits").move_cursor_down()
--     end,
--     desc = "Move to below split",
--   }
--   maps.n["<C-k>"] = {
--     function()
--       require("smart-splits").move_cursor_up()
--     end,
--     desc = "Move to above split",
--   }
--   maps.n["<C-l>"] = {
--     function()
--       require("smart-splits").move_cursor_right()
--     end,
--     desc = "Move to right split",
--   }
--   maps.n["<C-Up>"] = {
--     function()
--       require("smart-splits").resize_up()
--     end,
--     desc = "Resize split up",
--   }
--   maps.n["<C-Down>"] = {
--     function()
--       require("smart-splits").resize_down()
--     end,
--     desc = "Resize split down",
--   }
--   maps.n["<C-Left>"] = {
--     function()
--       require("smart-splits").resize_left()
--     end,
--     desc = "Resize split left",
--   }
--   maps.n["<C-Right>"] = {
--     function()
--       require("smart-splits").resize_right()
--     end,
--     desc = "Resize split right",
--   }
-- else
--   maps.n["<C-h>"] = { "<C-w>h", desc = "Move to left split" }
--   maps.n["<C-j>"] = { "<C-w>j", desc = "Move to below split" }
--   maps.n["<C-k>"] = { "<C-w>k", desc = "Move to above split" }
--   maps.n["<C-l>"] = { "<C-w>l", desc = "Move to right split" }
--   maps.n["<C-Up>"] = { "<cmd>resize -2<CR>", desc = "Resize split up" }
--   maps.n["<C-Down>"] = { "<cmd>resize +2<CR>", desc = "Resize split down" }
--   maps.n["<C-Left>"] = { "<cmd>vertical resize -2<CR>", desc = "Resize split left" }
--   maps.n["<C-Right>"] = { "<cmd>vertical resize +2<CR>", desc = "Resize split right" }
-- end

-- Telescope
-- if is_available("telescope.nvim") then
--   maps.n["<leader>f"] = sections.f
--   maps.n["<leader>g"] = sections.g
--   maps.n["<leader>gb"] = {
--     function()
--       require("telescope.builtin").git_branches()
--     end,
--     desc = "Git branches",
--   }
--   maps.n["<leader>gc"] = {
--     function()
--       require("telescope.builtin").git_commits()
--     end,
--     desc = "Git commits",
--   }
--   maps.n["<leader>gt"] = {
--     function()
--       require("telescope.builtin").git_status()
--     end,
--     desc = "Git status",
--   }
--   maps.n["<leader>f<CR>"] = {
--     function()
--       require("telescope.builtin").resume()
--     end,
--     desc = "Resume previous search",
--   }
--   maps.n["<leader>f'"] = {
--     function()
--       require("telescope.builtin").marks()
--     end,
--     desc = "Find marks",
--   }
--   maps.n["<leader>fa"] = {
--     function()
--       local cwd = vim.fn.stdpath("config") .. "/.."
--       local search_dirs = {}
--       for _, dir in ipairs(astronvim.supported_configs) do -- search all supported config locations
--         if dir == astronvim.install.home then
--           dir = dir .. "/lua/user"
--         end -- don't search the astronvim core files
--         if vim.fn.isdirectory(dir) == 1 then
--           table.insert(search_dirs, dir)
--         end -- add directory to search if exists
--       end
--       if vim.tbl_isempty(search_dirs) then -- if no config folders found, show warning
--         utils.notify("No user configuration files found", vim.log.levels.WARN)
--       else
--         if #search_dirs == 1 then
--           cwd = search_dirs[1]
--         end -- if only one directory, focus cwd
--         require("telescope.builtin").find_files({
--           prompt_title = "Config Files",
--           search_dirs = search_dirs,
--           cwd = cwd,
--         }) -- call telescope
--       end
--     end,
--     desc = "Find AstroNvim config files",
--   }
--   maps.n["<leader>fb"] = {
--     function()
--       require("telescope.builtin").buffers()
--     end,
--     desc = "Find buffers",
--   }
--   maps.n["<leader>fc"] = {
--     function()
--       require("telescope.builtin").grep_string()
--     end,
--     desc = "Find for word under cursor",
--   }
--   maps.n["<leader>fC"] = {
--     function()
--       require("telescope.builtin").commands()
--     end,
--     desc = "Find commands",
--   }
--   maps.n["<leader>ff"] = {
--     function()
--       require("telescope.builtin").find_files()
--     end,
--     desc = "Find files",
--   }
--   maps.n["<leader>fF"] = {
--     function()
--       require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
--     end,
--     desc = "Find all files",
--   }
--   maps.n["<leader>fh"] = {
--     function()
--       require("telescope.builtin").help_tags()
--     end,
--     desc = "Find help",
--   }
--   maps.n["<leader>fk"] = {
--     function()
--       require("telescope.builtin").keymaps()
--     end,
--     desc = "Find keymaps",
--   }
--   maps.n["<leader>fm"] = {
--     function()
--       require("telescope.builtin").man_pages()
--     end,
--     desc = "Find man",
--   }
--   if is_available("nvim-notify") then
--     maps.n["<leader>fn"] = {
--       function()
--         require("telescope").extensions.notify.notify()
--       end,
--       desc = "Find notifications",
--     }
--   end
--   maps.n["<leader>fo"] = {
--     function()
--       require("telescope.builtin").oldfiles()
--     end,
--     desc = "Find history",
--   }
--   maps.n["<leader>fr"] = {
--     function()
--       require("telescope.builtin").registers()
--     end,
--     desc = "Find registers",
--   }
--   maps.n["<leader>ft"] = {
--     function()
--       require("telescope.builtin").colorscheme({ enable_preview = true })
--     end,
--     desc = "Find themes",
--   }
--   maps.n["<leader>fw"] = {
--     function()
--       require("telescope.builtin").live_grep()
--     end,
--     desc = "Find words",
--   }
--   maps.n["<leader>fW"] = {
--     function()
--       require("telescope.builtin").live_grep({
--         additional_args = function(args)
--           return vim.list_extend(args, { "--hidden", "--no-ignore" })
--         end,
--       })
--     end,
--     desc = "Find words in all files",
--   }
--   maps.n["<leader>l"] = sections.l
--   maps.n["<leader>lD"] = {
--     function()
--       require("telescope.builtin").diagnostics()
--     end,
--     desc = "Search diagnostics",
--   }
--   maps.n["<leader>ls"] = {
--     function()
--       local aerial_avail, _ = pcall(require, "aerial")
--       if aerial_avail then
--         require("telescope").extensions.aerial.aerial()
--       else
--         require("telescope.builtin").lsp_document_symbols()
--       end
--     end,
--     desc = "Search symbols",
--   }
-- end
--
-- -- Terminal
-- if is_available("toggleterm.nvim") then
--   maps.n["<leader>t"] = sections.t
--   if vim.fn.executable("lazygit") == 1 then
--     maps.n["<leader>g"] = sections.g
--     maps.n["<leader>gg"] = {
--       function()
--         utils.toggle_term_cmd("lazygit")
--       end,
--       desc = "ToggleTerm lazygit",
--     }
--     maps.n["<leader>tl"] = {
--       function()
--         utils.toggle_term_cmd("lazygit")
--       end,
--       desc = "ToggleTerm lazygit",
--     }
--   end
--   if vim.fn.executable("node") == 1 then
--     maps.n["<leader>tn"] = {
--       function()
--         utils.toggle_term_cmd("node")
--       end,
--       desc = "ToggleTerm node",
--     }
--   end
--   if vim.fn.executable("gdu") == 1 then
--     maps.n["<leader>tu"] = {
--       function()
--         utils.toggle_term_cmd("gdu")
--       end,
--       desc = "ToggleTerm gdu",
--     }
--   end
--   if vim.fn.executable("btm") == 1 then
--     maps.n["<leader>tt"] = {
--       function()
--         utils.toggle_term_cmd("btm")
--       end,
--       desc = "ToggleTerm btm",
--     }
--   end
--   local python = vim.fn.executable("python") == 1 and "python" or vim.fn.executable("python3") == 1 and "python3"
--   if python then
--     maps.n["<leader>tp"] = {
--       function()
--         utils.toggle_term_cmd(python)
--       end,
--       desc = "ToggleTerm python",
--     }
--   end
--   maps.n["<leader>tf"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" }
--   maps.n["<leader>th"] = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal split" }
--   maps.n["<leader>tv"] = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical split" }
--   maps.n["<F7>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" }
--   maps.t["<F7>"] = maps.n["<F7>"]
--   maps.n["<C-'>"] = maps.n["<F7>"] -- requires terminal that supports binding <C-'>
--   maps.t["<C-'>"] = maps.n["<F7>"] -- requires terminal that supports binding <C-'>
-- end

-- if is_available("nvim-dap") then
--   maps.n["<leader>d"] = sections.d
--   maps.v["<leader>d"] = sections.d
--   -- modified function keys found with `showkey -a` in the terminal to get key code
--   -- run `nvim -V3log +quit` and search through the "Terminal info" in the `log` file for the correct keyname
--   maps.n["<F5>"] = {
--     function()
--       require("dap").continue()
--     end,
--     desc = "Debugger: Start",
--   }
--   maps.n["<F17>"] = {
--     function()
--       require("dap").terminate()
--     end,
--     desc = "Debugger: Stop",
--   } -- Shift+F5
--   maps.n["<F21>"] = {
--     function()
--       vim.ui.input({ prompt = "Condition: " }, function(condition)
--         if condition then
--           require("dap").set_breakpoint(condition)
--         end
--       end)
--     end,
--     desc = "Debugger: Conditional Breakpoint",
--   }
--   maps.n["<F29>"] = {
--     function()
--       require("dap").restart_frame()
--     end,
--     desc = "Debugger: Restart",
--   } -- Control+F5
--   maps.n["<F6>"] = {
--     function()
--       require("dap").pause()
--     end,
--     desc = "Debugger: Pause",
--   }
--   maps.n["<F9>"] = {
--     function()
--       require("dap").toggle_breakpoint()
--     end,
--     desc = "Debugger: Toggle Breakpoint",
--   }
--   maps.n["<F10>"] = {
--     function()
--       require("dap").step_over()
--     end,
--     desc = "Debugger: Step Over",
--   }
--   maps.n["<F11>"] = {
--     function()
--       require("dap").step_into()
--     end,
--     desc = "Debugger: Step Into",
--   }
--   maps.n["<F23>"] = {
--     function()
--       require("dap").step_out()
--     end,
--     desc = "Debugger: Step Out",
--   } -- Shift+F11
--   maps.n["<leader>db"] = {
--     function()
--       require("dap").toggle_breakpoint()
--     end,
--     desc = "Toggle Breakpoint (F9)",
--   }
--   maps.n["<leader>dB"] = {
--     function()
--       require("dap").clear_breakpoints()
--     end,
--     desc = "Clear Breakpoints",
--   }
--   maps.n["<leader>dc"] = {
--     function()
--       require("dap").continue()
--     end,
--     desc = "Start/Continue (F5)",
--   }
--   maps.n["<leader>dC"] = {
--     function()
--       vim.ui.input({ prompt = "Condition: " }, function(condition)
--         if condition then
--           require("dap").set_breakpoint(condition)
--         end
--       end)
--     end,
--     desc = "Conditional Breakpoint (S-F9)",
--   }
--   maps.n["<leader>di"] = {
--     function()
--       require("dap").step_into()
--     end,
--     desc = "Step Into (F11)",
--   }
--   maps.n["<leader>do"] = {
--     function()
--       require("dap").step_over()
--     end,
--     desc = "Step Over (F10)",
--   }
--   maps.n["<leader>dO"] = {
--     function()
--       require("dap").step_out()
--     end,
--     desc = "Step Out (S-F11)",
--   }
--   maps.n["<leader>dq"] = {
--     function()
--       require("dap").close()
--     end,
--     desc = "Close Session",
--   }
--   maps.n["<leader>dQ"] = {
--     function()
--       require("dap").terminate()
--     end,
--     desc = "Terminate Session (S-F5)",
--   }
--   maps.n["<leader>dp"] = {
--     function()
--       require("dap").pause()
--     end,
--     desc = "Pause (F6)",
--   }
--   maps.n["<leader>dr"] = {
--     function()
--       require("dap").restart_frame()
--     end,
--     desc = "Restart (C-F5)",
--   }
--   maps.n["<leader>dR"] = {
--     function()
--       require("dap").repl.toggle()
--     end,
--     desc = "Toggle REPL",
--   }
--   maps.n["<leader>ds"] = {
--     function()
--       require("dap").run_to_cursor()
--     end,
--     desc = "Run To Cursor",
--   }
--
--   if is_available("nvim-dap-ui") then
--     maps.n["<leader>dE"] = {
--       function()
--         vim.ui.input({ prompt = "Expression: " }, function(expr)
--           if expr then
--             require("dapui").eval(expr)
--           end
--         end)
--       end,
--       desc = "Evaluate Input",
--     }
--     maps.v["<leader>dE"] = {
--       function()
--         require("dapui").eval()
--       end,
--       desc = "Evaluate Input",
--     }
--     maps.n["<leader>du"] = {
--       function()
--         require("dapui").toggle()
--       end,
--       desc = "Toggle Debugger UI",
--     }
--     maps.n["<leader>dh"] = {
--       function()
--         require("dap.ui.widgets").hover()
--       end,
--       desc = "Debugger Hover",
--     }
--   end
-- end

-- Improved Code Folding
-- if is_available("nvim-ufo") then
--   maps.n["zR"] = {
--     function()
--       require("ufo").openAllFolds()
--     end,
--     desc = "Open all folds",
--   }
--   maps.n["zM"] = {
--     function()
--       require("ufo").closeAllFolds()
--     end,
--     desc = "Close all folds",
--   }
--   maps.n["zr"] = {
--     function()
--       require("ufo").openFoldsExceptKinds()
--     end,
--     desc = "Fold less",
--   }
--   maps.n["zm"] = {
--     function()
--       require("ufo").closeFoldsWith()
--     end,
--     desc = "Fold more",
--   }
--   maps.n["zp"] = {
--     function()
--       require("ufo").peekFoldedLinesUnderCursor()
--     end,
--     desc = "Peek fold",
--   }
-- end
--
-- maps.n["<leader>u"] = sections.u
-- -- Custom menu for modification of the user experience
-- if is_available("nvim-autopairs") then
--   maps.n["<leader>ua"] = { ui.toggle_autopairs, desc = "Toggle autopairs" }
-- end
-- maps.n["<leader>ub"] = { ui.toggle_background, desc = "Toggle background" }
-- if is_available("nvim-cmp") then
--   maps.n["<leader>uc"] = { ui.toggle_cmp, desc = "Toggle autocompletion" }
-- end
-- if is_available("nvim-colorizer.lua") then
--   maps.n["<leader>uC"] = { "<cmd>ColorizerToggle<cr>", desc = "Toggle color highlight" }
-- end
-- maps.n["<leader>ud"] = { ui.toggle_diagnostics, desc = "Toggle diagnostics" }
-- maps.n["<leader>ug"] = { ui.toggle_signcolumn, desc = "Toggle signcolumn" }
-- maps.n["<leader>ui"] = { ui.set_indent, desc = "Change indent setting" }
-- maps.n["<leader>ul"] = { ui.toggle_statusline, desc = "Toggle statusline" }
-- maps.n["<leader>uL"] = { ui.toggle_codelens, desc = "Toggle CodeLens" }
-- maps.n["<leader>un"] = { ui.change_number, desc = "Change line numbering" }
-- maps.n["<leader>uN"] = { ui.toggle_ui_notifications, desc = "Toggle UI notifications" }
-- maps.n["<leader>up"] = { ui.toggle_paste, desc = "Toggle paste mode" }
-- maps.n["<leader>us"] = { ui.toggle_spell, desc = "Toggle spellcheck" }
-- maps.n["<leader>uS"] = { ui.toggle_conceal, desc = "Toggle conceal" }
-- maps.n["<leader>ut"] = { ui.toggle_tabline, desc = "Toggle tabline" }
-- maps.n["<leader>uu"] = { ui.toggle_url_match, desc = "Toggle URL highlight" }
-- maps.n["<leader>uw"] = { ui.toggle_wrap, desc = "Toggle wrap" }
-- maps.n["<leader>uy"] = { ui.toggle_syntax, desc = "Toggle syntax highlight" }
-- maps.n["<leader>uh"] = { ui.toggle_foldcolumn, desc = "Toggle foldcolumn" }

local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
  commit = "ce741eb559c924d72e3a67d2189ad3771a231414",
}

function M.config()
  local mappings = {
    ["q"] = { "<cmd>confirm q<CR>", "Quit" },
    ["/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment" },
    ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
    ["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
    b = {
      name = "Buffers",
      b = { "<cmd>Telescope buffers previewer=false<cr>", "Find" },
    },
    d = {
      name = "Debug",
      t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
      b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
      c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
      C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
      d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
      g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
      i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
      o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
      u = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
      p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
      r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
      s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
      q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
      U = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
    },
    p = {
      name = "Plugins",
      i = { "<cmd>Lazy install<cr>", "Install" },
      s = { "<cmd>Lazy sync<cr>", "Sync" },
      S = { "<cmd>Lazy clear<cr>", "Status" },
      c = { "<cmd>Lazy clean<cr>", "Clean" },
      u = { "<cmd>Lazy update<cr>", "Update" },
      p = { "<cmd>Lazy profile<cr>", "Profile" },
      l = { "<cmd>Lazy log<cr>", "Log" },
      d = { "<cmd>Lazy debug<cr>", "Debug" },
    },

    f = {
      name = "Find",
      b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
      c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
      f = { "<cmd>Telescope find_files<cr>", "Find files" },
      p = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", "Projects" },
      t = { "<cmd>Telescope live_grep<cr>", "Find Text" },
      s = { "<cmd>Telescope grep_string<cr>", "Find String" },
      h = { "<cmd>Telescope help_tags<cr>", "Help" },
      H = { "<cmd>Telescope highlights<cr>", "Highlights" },
      i = { "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", "Media" },
      l = { "<cmd>Telescope resume<cr>", "Last Search" },
      M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
      r = { "<cmd>Telescope oldfiles<cr>", "Recent File" },
      R = { "<cmd>Telescope registers<cr>", "Registers" },
      k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
      C = { "<cmd>Telescope commands<cr>", "Commands" },
    },

    g = {
      name = "Git",
      g = { "<cmd>Neogit<cr>", "Neogit" },
      j = { "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", "Next Hunk" },
      k = { "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", "Prev Hunk" },
      l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
      p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
      r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
      R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
      s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
      u = {
        "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
        "Undo Stage Hunk",
      },
      o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
      b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
      c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
      C = {
        "<cmd>Telescope git_bcommits<cr>",
        "Checkout commit(for current file)",
      },
      d = {
        "<cmd>Gitsigns diffthis HEAD<cr>",
        "Git Diff",
      },
    },

    l = {
      name = "LSP",
      a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
      d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
      w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
      f = { "<cmd>lua vim.lsp.buf.format({timeout_ms = 1000000})<cr>", "Format" },
      i = { "<cmd>LspInfo<cr>", "Info" },
      I = { "<cmd>Mason<cr>", "Mason Info" },
      j = {
        "<cmd>lua vim.diagnostic.goto_next()<cr>",
        "Next Diagnostic",
      },
      k = {
        "<cmd>lua vim.diagnostic.goto_prev()<cr>",
        "Prev Diagnostic",
      },
      l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
      q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
      r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
      s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
      S = {
        "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        "Workspace Symbols",
      },
      e = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
    },

    t = {
      name = "Tab",
      t = {
        "<cmd>lua require('telescope').extensions['telescope-tabs'].list_tabs(require('telescope.themes').get_dropdown{previewer = false, initial_mode='normal', prompt_title='Tabs'})<cr>",
        "Find Tab",
      },
      a = { "<cmd>$tabnew<cr>", "New Empty Tab" },
      A = { "<cmd>tabnew %<cr>", "New Tab" },
      n = { "<cmd>tabn<cr>", "Next" },
      o = { "<cmd>tabonly<cr>", "Only" },
      p = { "<cmd>tabp<cr>", "Prev" },
      h = { "<cmd>-tabmove<cr>", "Move Left" },
      l = { "<cmd>+tabmove<cr>", "Move Right" },
    },

    T = {
      name = "Treesitter",
      i = { ":TSConfigInfo<cr>", "Info" },
    },
  }

  local opts = {
    mode = "n", -- NORMAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true, -- use `nowait` when creating keymaps
  }

  -- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
  -- see https://neovim.io/doc/user/map.html#:map-cmd
  local vmappings = {
    ["/"] = { "<Plug>(comment_toggle_linewise_visual)", "Comment toggle linewise (visual)" },
    l = {
      name = "LSP",
      a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    },
  }

  local vopts = {
    mode = "v", -- VISUAL mode
    prefix = "<leader>",
    buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true, -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true, -- use `nowait` when creating keymaps
  }

  local which_key = require("which-key")

  which_key.setup({
    plugins = {
      marks = false, -- shows a list of your marks on ' and `
      registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      spelling = {
        enabled = true,
        suggestions = 20,
      }, -- use which-key for spelling hints
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = false, -- adds help for operators like d, y, ...
        motions = false, -- adds help for motions
        text_objects = false, -- help for text objects triggered after entering an operator
        windows = false, -- default bindings on <c-w>
        nav = false, -- misc bindings to work with windows
        z = false, -- bindings for folds, spelling and others prefixed with z
        g = false, -- bindings for prefixed with g
      },
    },
    popup_mappings = {
      scroll_down = "<c-d>", -- binding to scroll down inside the popup
      scroll_up = "<c-u>", -- binding to scroll up inside the popup
    },
    window = {
      border = "rounded", -- none, single, double, shadow
      position = "bottom", -- bottom, top
      margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
      align = "left", -- align columns left, center or right
    },
    ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true, -- show help message on the command line when the popup is visible
    show_keys = true, -- show the currently pressed key and its label as a message in the command line
    triggers = "auto", -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_blacklist = {
      -- list of mode / prefixes that should never be hooked by WhichKey
      -- this is mostly relevant for key maps that start with a native binding
      -- most people should not need to change this
      i = { "j", "k" },
      v = { "j", "k" },
    },
    -- disable the WhichKey popup for certain buf types and file types.
    -- Disabled by default for Telescope
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  })

  which_key.register(mappings, opts)
  which_key.register(vmappings, vopts)
end

-- return M
