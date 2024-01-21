-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
if true then return {} end

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtins = require("telescope.builtin")
local action_set = require("telescope.actions.set")
-- local my_actions = require("dpetka2001.harpoon")

local Util = require("lazyvim.util")

local multi_open = function(pb)
  local picker = action_state.get_current_picker(pb)
  local multi = picker:get_multi_selection()
  -- my_actions.mark_file(pb)
  actions.select_default(pb) -- the normal enter behaviour
  for _, j in pairs(multi) do
    if j.path ~= nil then -- is it a file -> open it as well:
      vim.cmd(string.format("%s %s", "edit", j.path))
    end
  end
end

local picker_config = {}
for builtin, _ in pairs(builtins) do
  picker_config[builtin] = {
    -- Don't show the matched line since it is already in the preview.
    show_line = false,
    -- Center and unfold when selecting a result.
    attach_mappings = function(prompt_bufnr, _)
      action_set.select:enhance({
        post = function()
          vim.cmd(":normal! zv")
        end,
      })
      actions.center(prompt_bufnr)

      return true
    end,
  }
end

local cfg_return_this = {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-project.nvim",
        keys = {
          { "<C-p>", "<cmd>lua require'telescope'.extensions.project.project{}<cr>", desc = "Telescope Project" },
        },
      },
      -- {
      --   "nvim-telescope/telescope-fzf-native.nvim",
      --   build = "make",
      -- },
      { "natecraddock/telescope-zf-native.nvim" },
      { "debugloop/telescope-undo.nvim" },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-b>"] = function(...)
              return require("telescope.actions").delete_buffer(...)
            end,
            -- Add opening multi-selection support to telescope pickers
            ["<CR>"] = multi_open,
            ["<c-a-t>"] = actions.select_tab,
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<Tab>"] = require("dpetka2001.harpoon").mark_file,
          },
          n = {
            ["<C-b>"] = function(...)
              return require("telescope.actions").delete_buffer(...)
            end,
            -- Add opening multi-selection support to telescope pickers
            ["<CR>"] = multi_open,
            ["<Tab>"] = require("dpetka2001.harpoon").mark_file,
          },
        },
        layout_strategy = "flex",
        layout_config = {
          horizontal = {
            preview_width = 0.45,
          },
          vertical = {
            width = 0.9,
            height = 0.95,
            preview_height = 0.5,
            preview_cutoff = 0,
          },
          flex = {
            flip_columns = 140,
          },
        },
      },
      -- pickers = {
      --   buffers = {
      --     initial_mode = "normal",
      --   },
      -- },
      pickers = vim.tbl_deep_extend("force", picker_config, {
        -- Open Telescope even if there's only one result.
        lsp_references = { jump_type = "never" },
        lsp_definitions = { jump_type = "never" },
        buffers = { initial_mode = "normal" },
      }),
      extensions = {
        project = {
          base_dirs = {
            { path = "~/Desktop/Projects/" },
            { path = "~/projects/plugins/" },
            { path = "~/.local/share/chezmoi/" },
            { path = "~/.local/share/nvim/" },
          },
        },
        undo = {
          side_by_side = true,
        },
      },
    },
    keys = {
      { "<leader>sd", false },
      { "<leader>sD", false },
      { "<leader>sR", false },
      { "<leader>xd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
      { "<leader>xD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>xs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "LSP Document Symbols" },
      { "<leader>xS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "LSP Workspace Symbols" },
      { "<leader>sM", "<cmd>Telescope man_pages sections=ALL<cr>", desc = "Man Pages" },
      { "<leader>ff", Util.telescope("find_files"), desc = "Find files (root dir not git)" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Current Buffer Fuzzy" },
      { "<leader>gb", "<cmd>Telescope git_bcommits<cr>", desc = "Buffer commits" },
      { "<leader>U", "<cmd>Telescope undo<cr>", desc = "Telescope undo" },
    },
    -- Setup here extensions that depend on `telescope.opts`, otherwise just setup when it is called
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("project")
      telescope.load_extension("zf-native")
      telescope.load_extension("undo")
      -- telescope.load_extension("fzf")
    end,
  },

  -- Modify `alpha.nvim` to include `telescope-project`
  {
    "goolord/alpha-nvim",
    opts = function(_, dashboard)
      local button = dashboard.button("p", " " .. " Projects", ":Telescope project <CR>")
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
      table.insert(dashboard.section.buttons.val, 4, button)
    end,
  },
}

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
local cfg2_return_this = {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- disable trouble
  { "folke/trouble.nvim", enabled = false },

  -- add symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },

  -- override nvim-cmp and add cmp-emoji
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" } }))
    end,
  },

  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },

  -- add telescope-fzf-native
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },

  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
      },
    },
  },

  -- add tsserver and setup with typescript.nvim instead of lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
        end)
      end,
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {},
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts })
          return true
        end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
  },

  -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
  -- would overwrite `ensure_installed` with the new value.
  -- If you'd rather extend the default config, use the code below instead:
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
      })
    end,
  },

  -- the opts function can also be used to change the default opts:
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, "😄")
    end,
  },

  -- or you can return new options to override all the defaults
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        --[[add your custom lualine config here]]
      }
    end,
  },

  -- use mini.starter instead of alpha
  { import = "lazyvim.plugins.extras.ui.mini-starter" },

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" },

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },

  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = "nvim-lua/plenary.nvim",
    keys = {
      { "<C-t>", "<CMD>Telescope<CR>", mode = { "n", "i", "v" } },
      { "<C-p>", "<CMD>Telescope find_files<CR>", mode = { "n", "i", "v" } },
      { "<C-l>", "<CMD>Telescope live_grep<CR>", mode = { "n", "i", "v" } },
      { "<C-c>", "<CMD>Telescope commands<CR>", mode = { "n", "i", "v" } },
      { "<C-k>", "<CMD>Telescope keymaps<CR>", mode = { "n", "i", "v" } },
      { "<C-s>", "<CMD>Telescope grep_string<CR>", mode = { "n", "i", "v" } },
    },
    config = true,
  },
  -- Git Diff
  -- gitui
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "TimUntersberger/neogit", config = { disable_commit_confirmation = true } },
    },
    commit = "9359f7b1dd3cb9fb1e020f57a91f8547be3558c6", -- HEAD requires git 2.31
    keys = {
      { "<C-g>", "<CMD>DiffviewOpen<CR>", mode = { "n", "i", "v" } },
    },
    config = {
      keymaps = {
        view = {
          ["<C-g>"] = "<CMD>DiffviewClose<CR>",
          ["c"] = "<CMD>DiffviewClose|Neogit commit<CR>",
        },
        file_panel = {
          ["<C-g>"] = "<CMD>DiffviewClose<CR>",
          ["c"] = "<CMD>DiffviewClose|Neogit commit<CR>",
        },
      },
    },
  },
  { "eandrju/cellular-automaton.nvim" },
}

local icons = require("lazyvim.config").icons
local Util = require("lazyvim.util")

return {
  -- Modify nvim-dap
  {
    "mfussenegger/nvim-dap",
      -- stylua: ignore
      keys = {
        { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
        { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
        { "<F12>", function() require("dap").step_out() end, desc = "Step Out" },
      },
  },

  -- Change default permissions for files created via Neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        window = {
          mappings = {
            ["L"] = "open_nofocus",
          },
        },
        commands = {
          open_nofocus = function(state)
            require("neo-tree.sources.filesystem.commands").open(state)
            vim.schedule(function()
              vim.cmd([[Neotree focus]])
            end)
          end,
        },
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
      event_handlers = {
        {
          event = "file_added",
          handler = function(destination)
            local uv = vim.loop
            local file_info = uv.fs_stat(destination)
            if not file_info then
              return
            elseif file_info.type == "file" then
              uv.fs_chmod(destination, 436) -- (436 base 10) == (664 base 8)
            elseif file_info.type == "directory" then
              uv.fs_chmod(destination, 509) -- 644 does not work for directories I guess?
            end
          end,
        },
      },
    },
  },

  -- Modify gitsigns
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        map("n", "<leader>ght", gs.toggle_current_line_blame, "Toggle Blame Line")
      end,
    },
  },

  -- Modify todo-comments
  {
    "folke/todo-comments.nvim",
    opts = {
      highlight = {
        keyword = "bg",
        -- add extra pattern for `KEYWORD(AUTHOR):`
        pattern = { [[.*<(KEYWORDS)\s*:]], [[.*<(KEYWORDS)\s*[(][^)]*[)]:]] },
      },
    },
  },

  -- Modify `flash.nvim`
  {
    "folke/flash.nvim",
    keys = {
      -- Disable default mappings, cuz they conflict with `vim-surround`
      { "s", mode = { "n", "x", "o" }, false },
      { "S", mode = { "n", "x", "o" }, false },
      {
        "m",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "M",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
    opts = {
      modes = {
        -- Disable labels for regular search with `/`
        search = {
          enabled = false,
        },
        -- Modify options used by `flash` when doing `f`, `F`, `t`, `T` motions
        char = {
          jump_labels = true,
        },
      },
    },
  },

  -- Try out `fzf-lua`
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    opts = {},
  },

  ---@diagnostic disable: missing-fields
  -- Customize LSP
  {
    "neovim/nvim-lspconfig",
    -- Add, change or remove keymaps
    init = function()
      -- disable lsp watcher. Too slow on linux
      local ok, wf = pcall(require, "vim.lsp._watchfiles")
      if ok then
        wf._watchfunc = function()
          return function() end
        end
      end

      --[[Modify LSP keymaps]]
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "gD", false }
      keys[#keys + 1] = { "<leader>cl", false }
      keys[#keys + 1] = { "<leader>cli", "<cmd>LspInfo<cr>", desc = "LspInfo" }
      keys[#keys + 1] =
        { "<leader>clr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", desc = "Remove workspace" }
      keys[#keys + 1] = { "<leader>cla", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", desc = "Add workspace" }
      keys[#keys + 1] = {
        "<leader>cll",
        "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
        desc = "List workspace",
      }
      keys[#keys + 1] = {
        "K",
        function()
          require("pretty_hover").hover()
        end,
        desc = "Hover",
      }

      require("which-key").register({
        ["<leader>cl"] = { name = "+lsp" },
      })
    end,
    opts = {
      diagnostics = {
        virtual_text = {
          prefix = "icons",
          spacing = 4,
          source = "if_many",
        },
        -- virtual_text = false,
      },
      inlay_hints = {
        -- enabled = true,
      },
      servers = {
        yamlls = {},
        tsserver = {
          -- Need to disable this cuz `Inline Edit` won't work otherwise
          -- single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                -- disable = { "missing-parameter" },
              },
              hint = {
                enable = true,
                setType = true,
                paramType = true,
                paramName = "All",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
    },
    dependencies = {
      {
        "SmiteshP/nvim-navbuddy",
        lazy = true,
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
        },
        opts = { lsp = { auto_attach = true } },
        keys = {
          { "<leader>cln", "<cmd>Navbuddy<cr>", desc = "Lsp Navigation" },
        },
      },

      {
        "simrat39/symbols-outline.nvim",
        lazy = true,
        keys = {
          { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" },
        },
        opts = {
          width = 35,
          autofold_depth = 2,
        },
      },

      -- Pretty hover
      {
        "Fildo7525/pretty_hover",
        event = "LspAttach",
        opts = {},
      },
    },
  },

  -- Modify `null-ls`
  {
    "jose-elias-alvarez/null-ls.nvim",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client.name == "null-ls" then
            vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>cn", "<cmd>NullLsInfo<cr>", { desc = "NullLs Info" })
          end
        end,
      })
    end,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources, {
        nls.builtins.code_actions.gitsigns,
      })
    end,
  },

  -- Modify nvim-notify for Telescope
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>und",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Delete all Notifications",
      },
      {
        "<leader>unt",
        function()
          if Util.has("telescope.nvim") then
            require("telescope").extensions.notify.notify({
              initial_mode = "normal",
              -- layout_strategy = "vertical",
            })
          else
            Util.on_load("which-key.nvim", function()
              require("which-key").register({
                ["<leader>unt"] = "which_key_ignore",
              })
              vim.keymap.del("n", "<leader>unt")
            end)
          end
        end,
        desc = "Open Notifications (Telescope)",
      },
    },
  },

  -- Modify `bufferline`
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    -- event = function()
    --   return { "BufReadPost", "BufNewFile" }
    -- end,
    opts = {
      options = {
        always_show_bufferline = true,
        -- custom_filter = function(buf, _)
        --   -- get the current tab page number
        --   local current_tab = vim.api.nvim_get_current_tabpage()
        --   -- get a list of buffers for a specific tab
        --   local tab_buffers = vim.fn.tabpagebuflist(current_tab)
        --   -- check if the current buffer is being viewed in the current tab
        --   return vim.tbl_contains(tab_buffers, buf)
        -- end,
        -- custom_filter = function(buf_number)
        --   if not not vim.api.nvim_buf_get_name(buf_number):find(vim.fn.getcwd(), 0, true) then
        --     return true
        --   end
        -- end,
      },
    },
  },

  -- Modify `lualine`
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      sections = {
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
            -- stylua: ignore
            {
              function() return require("nvim-navic").get_location() end,
              cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
              -- For other colorschemes that have a weird space at the end
              padding = { left =1, right = 0 },
            },
        },
        lualine_z = {},
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local timer = function()
        return require("nomodoro").status()
      end
      table.insert(opts.sections.lualine_x, { "encoding" })
      table.insert(opts.sections.lualine_x, { timer })
    end,
  },

  -- Style windows with different colorschemes
  {
    "folke/styler.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      themes = {
        markdown = { colorscheme = "catppuccin" },
        help = { colorscheme = "catppuccin", background = "dark" },
      },
    },
  },

  -- `indent-blankline` alternative with some extra features
  -- {
  --   "shellRaining/hlchunk.nvim",
  --   event = { "UIEnter" },
  --   opts = {
  --     indent = {
  --       enable = false,
  --     },
  --     blank = {
  --       enable = false,
  --     },
  --     line_num = {
  --       enable = false,
  --     },
  --     chunk = {
  --       chars = {
  --         horizontal_line = "─",
  --         vertical_line = "│",
  --         left_top = "╭",
  --         left_bottom = "╰",
  --         right_arrow = ">",
  --       },
  --       style = "#00ffff",
  --     },
  --   },
  -- },
}
