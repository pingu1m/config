if true then
  return {
    -- Import extra lsp languages configs
    -- { import = "plugins.extras.lang" },
    { "folke/zen-mode.nvim" },
    {
      "nvim-neorg/neorg",
      build = ":Neorg sync-parsers",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("neorg").setup({
          load = {
            ["core.defaults"] = {}, -- Loads default behaviour
            ["core.concealer"] = {}, -- Adds pretty icons to your documents
            ["core.dirman"] = { -- Manages Neorg workspaces
              config = {
                workspaces = {
                  notes = "~/notes",
                },
              },
            },
          },
        })
      end,
    },
    {
      "numToStr/Comment.nvim",
      opts = {
        -- add any options here
      },
      lazy = false,
    },
    {
      "akinsho/toggleterm.nvim",
      lazy = true,
      keys = {
        {
          "<leader>t1",
          function()
            require("toggleterm").toggle(1, 0, Util.get_root(), "float")
          end,
          desc = "ToggleTerm (float)",
        },
        {
          "<leader>t2",
          function()
            require("toggleterm").toggle(2, 0, Util.get_root(), "float")
          end,
          desc = "ToggleTerm (float)",
        },
        -- {
        --   "<leader>t4",
        --   function()
        --     local count = vim.v.count1
        --     require("toggleterm").toggle(count, 0, Util.get_root(), "float")
        --     -- require("toggleterm").toggle(count, 10, Util.get_root(), "horizontal")
        --     -- require("toggleterm").toggle(1, 100, Util.get_root(), "tab")
        --     -- require("toggleterm").toggle(1, 100, vim.loop.cwd(), "tab")
        --   end,
        --   desc = "ToggleTerm (float)",
        -- },
        -- {
        --   "<leader>tn",
        --   "<cmd>ToggleTermSetName<cr>",
        --   desc = "Set term name",
        -- },
        {
          "<leader>ts",
          "<cmd>TermSelect<cr>",
          desc = "Select term",
        },
      },
      opts = {
        -- size can be a number or function which is passed the current terminal
        size = 20 or function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        -- open_mapping = [[<c-\>]],
        -- on_open = fun(t: Terminal), -- function to run when the terminal opens
        -- on_close = fun(t: Terminal), -- function to run when the terminal closes
        -- on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
        -- on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
        -- on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        shade_terminals = true,
        -- shading_factor = '<number>', -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        persist_size = true,
        direction = "horizontal" or "vertical" or "window" or "float",
        -- direction = "vertical",
        close_on_exit = true, -- close the terminal window when the process exits
        -- shell = vim.o.shell, -- change the default shell
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
          --   -- The border key is *almost* the same as 'nvim_open_win'
          --   -- see :h nvim_open_win for details on borders however
          --   -- the 'curved' border is a custom border type
          --   -- not natively supported but implemented in this plugin.
          border = "curved" or "double" or "shadow" or "single",
          --   width = <value>,
          --   height = <value>,
          --   winblend = 3,
          --   highlights = {
          --     border = "Normal",
          --     background = "Normal",
          --   }
        },
      },
    },
  }
end

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
