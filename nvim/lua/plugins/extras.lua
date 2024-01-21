local ui = require("fg.components")

return {
  { "eandrju/cellular-automaton.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- disable the keymap to grep files
      { "<leader>/", false },
      { "<leader><leader>", false },
      -- change a keymap
      -- { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      -- add a keymap to browse plugin files
    },
  },
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
    },
  },
  { "folke/zen-mode.nvim" },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "nvim-lualine/lualine.nvim",
    -- dependencies = {
    --   -- "nvim-tree/nvim-web-devicons",
    --   -- "SmiteshP/nvim-navic",
    --   -- "onsails/lspkind-nvim",
    -- },
    -- lazy = false,
    -- priority = 999,
    event = "VeryLazy",
    opts = function()
      return ui.lualine.config2
    end,
  },
  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "numToStr/Comment.nvim",
    opts = {
      toggler = {
        ---Line-comment toggle keymap
        line = "gcc",
        ---Block-comment toggle keymap
        block = "gbc",
      },
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
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find("Windows"))
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    config = function()
      local ls = require("luasnip")

      require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/snippets/" } })
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/vscode_snippets/" } })
      -- ls.config.setup({ store_selection_keys = "<A-p>"})

      local types = require("luasnip.util.types")
      ls.config.set_config({
        history = true,
        delete_check_events = "TextChanged",
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
        ext_opts = {
          [types.choiceNode] = {
            active = {
              virt_text = { { "●", "GruvboxOrange" } },
            },
          },
          [types.insertNode] = {
            active = {
              virt_text = { { "●", "GruvboxBlue" } },
            },
          },
        },
      })
      -- TODO: add keybinding to quickly edit snippets
    end,
  -- stylua: ignore
  keys = {
    { "<a-k>", function() 
        if require("luasnip").jumpable(-1) then
          -- silent true
          require("luasnip").jump(-1)
        end
      end, mode = {"s", "i"} },
    { "<a-j>", function() 
        if require("luasnip").jumpable(1) then
          require("luasnip").jump(1)
        end
      end, mode = { "i", "s" } },
    { "<a-h>", function() 
        if require("luasnip").choice_active() then
          require("luasnip").change_choice(-1)
        end
      end, mode = { "i", "s" } },
    { "<a-l>", function() 
        if require("luasnip").choice_active() then
          require("luasnip").change_choice(1)
        end
      end, mode = { "i", "s" } },
    { "<a-p>", function() 
          if require("luasnip").expand_or_jumpable() then
            require("luasnip").expand()
          end
      end, mode = { "i", "s" } },
  },
  },
}
