local ui = require("fg.components")

return {
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
}
