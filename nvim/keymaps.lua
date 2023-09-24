local function map(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { silent = true })
end

local keymap = vim.keymap.set -- for conciseness

-- map("n", "Q", "<nop>")
keymap({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
map("n", "Q", function() print("Stop using Q man.") end)
---------------------
-- General Keymaps
---------------------

-- Save
map("n", "<leader>w", "<CMD>update<CR>")

-- Quit
map("n", "<leader>q", "<CMD>q<CR>")

-- Exit insert mode
map("i", "jk", "<ESC>")

-- clear search highlights
map("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
map("n", "x", '"_x')

-- increment/decrement numbers
map("n", "<leader>+", "<C-a>") -- increment
map("n", "<leader>-", "<C-x>") -- decrement

-- window management
map("n", "<leader>sv", "<C-w>v") -- split window vertically
map("n", "<leader>sh", "<C-w>s") -- split window horizontally
map("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
map("n", "<leader>sx", ":close<CR>") -- close current split window

map("n", "<leader>to", ":tabnew<CR>") -- open new tab
map("n", "<leader>tx", ":tabclose<CR>") -- close current tab
map("n", "<leader>tn", ":tabn<CR>") --  go to next tab
map("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

-- Navigate vim panes better
map('n', '<c-k>', ':wincmd k<CR>')
map('n', '<c-j>', ':wincmd j<CR>')
map('n', '<c-h>', ':wincmd h<CR>')
map('n', '<c-l>', ':wincmd l<CR>')

-- Buffer
map("n", "<TAB>", "<CMD>bnext<CR>")
map("n", "<S-TAB>", "<CMD>bprevious<CR>")

keymap("n", "<C-d>", "<C-d>zz",
  { desc = "scroll down and then center the cursorline" })

keymap("n", "<C-u>", "<C-u>zz",
  { desc = "scroll up and then center the cursorline" })


-- Tab/Shift+tab to indent/dedent
map("v", "<Tab>", ">gv")
map("n", "<Tab>", "v><C-\\><C-N>")
map("v", "<S-Tab>", "<gv")
map("n", "<S-Tab>", "v<<C-\\><C-N>")
-- map("i", "<S-Tab>", "<C-\\><C-N>v<<C-\\><C-N>^i")

-- Remap for dealing with word wrap
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- File Explorer
map("n", "<leader>pv", vim.cmd.Ex)

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
map({"n", "v"}, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])
map({"n", "v"}, "<leader>d", [["_d]])

-- wezterm todo
-- map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

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

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  keymap('t', '<esc>', [[<C-\><C-n>]], opts)
  keymap('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  keymap('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  keymap('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  keymap('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')



-- -- NeoTree
-- map("n", "<leader>e", "<CMD>Neotree toggle<CR>")
-- map("n", "<leader>o", "<CMD>Neotree focus<CR>")

-- -- Terminal
-- map("n", "<leader>th", "<CMD>ToggleTerm size=10 direction=horizontal<CR>")
-- map("n", "<leader>tv", "<CMD>ToggleTerm size=80 direction=vertical<CR>")

-- -- Markdown Preview
-- map("n", "<leader>m", "<CMD>MarkdownPreview<CR>")
-- map("n", "<leader>mn", "<CMD>MarkdownPreviewStop<CR>")


-- -- vim-maximizer
-- map("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle split window maximization

-- -- nvim-tree
-- map("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer

-- -- restart lsp server (not on youtube nvim video)
-- map("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary
-- map("n", "<leader>f", vim.lsp.buf.format)

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


















local km = vim.keymap

-- Here is a utility function that closes any floating windows when you press escape
local function close_floating()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end

--  ┌                                                                              ┐
--  │ These define common comment styles like this                                 │
--  └                                                                              ┘
km.set({ "n", "v" }, "<leader>x1", ":CBlbox12<cr>", { desc = "Comment - single side" })
km.set({ "n", "v" }, "<leader>x2", ":CBlbox18<cr>", { desc = "Comment - both sides" })
km.set("n", "<leader>x3", "CBline3<cr>", { desc = "Centered Line" })
km.set("n", "<leader>x4", "CBline5<cr>", { desc = "Centered Line Weighted" })

km.set("n", "<Leader>u", ":Lazy update<CR>", { desc = "Lazy Update (Sync)" })

km.set("n", "<Leader>n", "<cmd>enew<CR>", { desc = "New File" })

km.set("n", "<Leader>a", "ggVG<c-$>", { desc = "Select All" })

-- Make visual yanks place the cursor back where started
km.set("v", "y", "ygv<Esc>", { desc = "Yank and reposition cursor" })

km.set("n", "<Delete>", "<cmd>:w<CR>", { desc = "Save file" })

km.set("n", "<leader>xu", ":UndotreeToggle<cr>", { desc = "Undo Tree" })
-- More molecular undo of text
km.set("i", ".", ".<c-g>u")
km.set("i", "!", "!<c-g>u")
km.set("i", "?", "?<c-g>u")
km.set("i", ";", ";<c-g>u")
km.set("i", ":", ":<c-g>u")

km.set({ "n", "i" }, "<F1>", "<Esc>")

km.set("n", "<esc>", function()
  close_floating()
  vim.cmd(":noh")
end, { silent = true, desc = "Remove Search Highlighting, Dismiss Popups" })

km.set("n", "<leader>l", ":LazyGit<cr>", { silent = true, desc = "Lazygit" })

-- Easy delete buffer without losing window split
km.set("n", "<leader>d", ":lua MiniBufremove.delete()<cr>", { silent = true, desc = "Mini Bufremove" })

-- Easy add date/time
function date()
  local pos = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local nline = line:sub(0, pos) .. "# " .. os.date("%d.%m.%y") .. line:sub(pos + 1)
  vim.api.nvim_set_current_line(nline)
  vim.api.nvim_feedkeys("o", "n", true)
end

km.set("n", "<Leader>xd", "<cmd>lua date()<cr>", { desc = "Insert Date" })

km.set("n", "j", [[(v:count > 5 ? "m'" . v:count : "") . 'j']], { expr = true, desc = "if j > 5 add to jumplist" })

km.set("n", "<leader>p", function()
  require("telescope.builtin").find_files()
end, { desc = "Files Find" })

km.set("n", "<leader>r", function()
  require("telescope.builtin").registers()
end, { desc = "Browse Registers" })

km.set("n", "<leader>m", function()
  require("telescope.builtin").marks()
end, { desc = "Browse Marks" })

km.set("n", "<leader>f", function()
  require("telescope.builtin").live_grep()
end, { desc = "Find string" })

km.set("n", "<leader>b", function()
  require("telescope.builtin").buffers()
end, { desc = "Browse Buffers" })

km.set("n", "<leader>j", function()
  require("telescope.builtin").help_tags()
end, { desc = "Browse Help Tags" })

km.set("n", "<leader>gc", function()
  require("telescope.builtin").git_bcommits()
end, { desc = "Browse File Commits" })

km.set("n", "<leader>e", function()
  require("telescope").extensions.file_browser.file_browser()
end, { desc = "Files Explore" })

km.set("n", "<leader>s", function()
  require("telescope.builtin").spell_suggest(require("telescope.themes").get_cursor({}))
end, { desc = "Spelling Suggestions" })

km.set("n", "<leader>gs", function()
  require("telescope.builtin").git_status()
end, { desc = "Git Status" })

km.set("n", "<leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "Code Actions" })

km.set("n", "<leader>ch", function()
  vim.lsp.buf.hover()
end, { desc = "Code Hover" })

km.set("n", "<leader>cl", function()
  vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = "Line Diagnostics" })

km.set("n", "<leader>cs", function()
  require("telescope.builtin").lsp_document_symbols()
end, { desc = "Code Symbols" })

km.set("n", "<leader>cd", function()
  require("telescope.builtin").diagnostics({ bufnr = 0 })
end, { desc = "Code Diagnostics" })

km.set("n", "<leader>cr", function()
  require("telescope.builtin").lsp_references()
end, { desc = "Code References" })

km.set({ "v", "n" }, "<leader>cn", function()
  vim.lsp.buf.rename()
end, { noremap = true, silent = true, desc = "Code Rename" })

km.set("n", "<Leader><Down>", "<C-W><C-J>", { silent = true, desc = "Window Down" })
km.set("n", "<Leader><Up>", "<C-W><C-K>", { silent = true, desc = "Window Up" })
km.set("n", "<Leader><Right>", "<C-W><C-L>", { silent = true, desc = "Window Right" })
km.set("n", "<Leader><Left>", "<C-W><C-H>", { silent = true, desc = "Window Left" })
km.set("n", "<Leader>wr", "<C-W>R", { silent = true, desc = "Window Resize" })
km.set("n", "<Leader>=", "<C-W>=", { silent = true, desc = "Window Equalise" })

-- Easier window switching with leader + Number
-- Creates mappings like this: km.set("n", "<Leader>2", "2<C-W>w", { desc = "Move to Window 2" })
for i = 1, 6 do
  local lhs = "<Leader>" .. i
  local rhs = i .. "<C-W>w"
  km.set("n", lhs, rhs, { desc = "Move to Window " .. i })
end

km.set({ "n", "v" }, "h", ":Pounce<CR>", { silent = true, desc = "Pounce" })
km.set("n", "H", ":PounceRepeat<CR>", { silent = true, desc = "Pounce Repeat" })

-- thanks to https://www.reddit.com/r/neovim/comments/107g7yf/comment/j3o5a6f/?context=3 we can toggle the line mode changes in our options due to the correct variable being set here
km.set("n", "<leader>z", function()
  if vim.g.zen_mode_active then
    require("zen-mode").toggle()
    vim.g.zen_mode_active = false
  else
    require("zen-mode").toggle()
    vim.g.zen_mode_active = true
  end
end, { desc = "Zen Mode Toggle" })

km.set("i", "<A-BS>", "<C-W>", { desc = "Option+BS deletes whole word" })

km.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<cr>", { desc = "Git toggle line blame" })

km.set("n", "<Leader>xs", ":SearchSession<CR>", { desc = "Search Sessions" })

km.set(
  "v",
  "<leader>xp",
  ":'<,'> w !pandoc --no-highlight --wrap=none | pbcopy <CR>",
  { silent = true, desc = "Pandoc Export" }
)

km.set("n", "<Leader>xn", ":let @+=@%<cr>", { desc = "Copy Buffer name and path" })

km.set("n", "<Leader>xc", ":g/console.lo/d<cr>", { desc = "Remove console.log" })

-- These two keep the search in the middle of the screen.
km.set("n", "n", function()
  vim.cmd("silent normal! nzz")
end)

km.set("n", "N", function()
  vim.cmd("silent normal! Nzz")
end)

km.set("v", "<leader>o", "zA", { desc = "Toggle Fold" })

km.set({ "n", "x" }, "[p", '<Cmd>exe "put! " . v:register<CR>', { desc = "Paste Above" })
km.set({ "n", "x" }, "]p", '<Cmd>exe "put "  . v:register<CR>', { desc = "Paste Below" })
