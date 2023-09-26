-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- This file is automatically loaded by lazyvim.config.init
local Util = require("lazyvim.util")

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

map({ "i", "x", "n", "s" }, "<leader>s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- windows
map("n", "<leader>ww", "<cmd>w<cr><esc>", { desc = "Other window", remap = true })
map("n", "<leader>wc", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>we", "<C-w>=", { desc = "Make split equal dimentions" })

map("n", "<leader>wc", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("n", "x", '"_x', { desc = "Delete single char without copying into register" })

-- increment/decrement numbers
-- map("n", "<leader>+", "<C-a>") -- increment
-- map("n", "<leader>-", "<C-x>") -- decrement

-- SHIFT + H or L e muito bom pra isso below
-- map("n", "<TAB>", "<CMD>bnext<CR>", { desc = "Next Buffer" })
-- map("n", "<S-TAB>", "<CMD>bprevious<CR>", { desc = "Previous Buffer" })

map("n", "<C-d>", "<C-d>zz", { desc = "scroll down and then center the cursorline" })
map("n", "<C-u>", "<C-u>zz", { desc = "scroll up and then center the cursorline" })

-- Tab/Shift+tab to indent/dedent
map("v", "<Tab>", ">gv")
map("n", "<Tab>", "v><C-\\><C-N>")
map("v", "<S-Tab>", "<gv")
map("n", "<S-Tab>", "v<<C-\\><C-N>")
-- map("i", "<S-Tab>", "<C-\\><C-N>v<<C-\\><C-N>^i")

-- Remap for dealing with word wrap
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- Awesome mapping in visual mode move selected lines
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Join lines and keep cursor in place
map("n", "J", "mzJ`z")

-- next and prev search centering cursor
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- greatest remap ever
map("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])
map({ "n", "v" }, "<leader>d", [["_d]])

---------------------
-- General Keymaps
---------------------
-- Navigate quickfix window
-- map("n", "<C-k>", "<cmd>cnext<CR>zz")
-- map("n", "<C-j>", "<cmd>cprev<CR>zz")

-- same as cnext location used
-- map("n", "<leader>k", "<cmd>lnext<CR>zz")
-- map("n", "<leader>j", "<cmd>lprev<CR>zz")

-- ADHOC temporary
-- map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- map("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");

-- map("n", "<leader><leader>", function()
--     vim.cmd("so")
-- end)

-- restart lsp server (not on youtube nvim video)
map("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary
map("n", "<leader>f", vim.lsp.buf.format)

map("n", "<Leader>a", "ggVG<c-$>", { desc = "Select All" })
map("n", "<leader>xu", ":UndotreeToggle<cr>", { desc = "Undo Tree" })

-- local status, telescope = pcall(require, "telescope.builtin")
-- if status then
-- 	-- Telescope
-- 	map("n", "<leader>ff", telescope.find_files)
-- 	map("n", "<leader>fg", telescope.live_grep)
-- 	map("n", "<leader>fb", telescope.buffers)
-- 	map("n", "<leader>fh", telescope.help_tags)
-- 	map("n", "<leader>fs", telescope.git_status)
-- 	map("n", "<leader>fc", telescope.git_commits)
--   -- telescope
--   map("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
--   map("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
--   map("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
--   map("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
--   map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

--   -- telescope git commands (not on youtube nvim video)
--   map("n", "<leader>gc",  "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
--   map("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
--   map("n", "<leader>gb",  "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
--   map("n", "<leader>gs",  "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]
-- else
-- 	print("Telescope not found")
-- end

-- MUST HAVE
-- use 'eandrju/cellular-automaton.nvim'
-- map("n", "<leader>fml"<cmd>CellularAutomaton make_it_rain<CR>");

-- Here is a utility function that closes any floating windows when you press escape
local function close_floating()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end
map("n", "<esc>", function()
  close_floating()
  vim.cmd(":noh")
end, { silent = true, desc = "Remove Search Highlighting, Dismiss Popups" })

map("n", "<leader>l", ":LazyGit<cr>", { silent = true, desc = "Lazygit" })

-- Easy add date/time
function date()
  local pos = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local nline = line:sub(0, pos) .. "# " .. os.date("%d.%m.%y") .. line:sub(pos + 1)
  vim.api.nvim_set_current_line(nline)
  vim.api.nvim_feedkeys("o", "n", true)
end

map("n", "<Leader>xd", "<cmd>lua date()<cr>", { desc = "Insert Date" })

-- Easier window switching with leader + Number
-- Creates mappings like this: km.set("n", "<Leader>2", "2<C-W>w", { desc = "Move to Window 2" })
-- for i = 1, 6 do
--   local lhs = "<Leader>" .. i
--   local rhs = i .. "<C-W>w"
--   km.set("n", lhs, rhs, { desc = "Move to Window " .. i })
-- end

-- km.set("n", "<leader>f", function()
--   require("telescope.builtin").registers()
--   require("telescope.builtin").marks()
--   require("telescope.builtin").buffers()
--   require("telescope.builtin").help_tags()
--   require("telescope.builtin").git_bcommits()
--   require("telescope").extensions.file_browser.file_browser()
--   require("telescope.builtin").live_grep()
--   require("telescope.builtin").git_status()
--   require("telescope.builtin").lsp_document_symbols()
--   require("telescope.builtin").diagnostics({ bufnr = 0 })
--   require("telescope.builtin").lsp_references()
-- end, { desc = "Find string" })
--
-- km.set("n", "<leader>ca", function()
--   vim.lsp.buf.code_action()
--   vim.lsp.buf.hover()
--   vim.diagnostic.open_float(0, { scope = "line" })
--   vim.lsp.buf.rename()
-- end, { desc = "Code Actions" })

map("n", "<leader>z", function()
  if vim.g.zen_mode_active then
    require("zen-mode").toggle()
    vim.g.zen_mode_active = false
  else
    require("zen-mode").toggle()
    vim.g.zen_mode_active = true
  end
end, { desc = "Zen Mode Toggle" })

map("n", "<Leader>xn", ":let @+=@%<cr>", { desc = "Copy Buffer name and path" })
map("n", "<Leader>xc", ":g/console.lo/d<cr>", { desc = "Remove console.log" })
