return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      theme = "tokyonight",
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
    },
    sections = {
      lualine_a = {
        {
          "mode",
          fmt = function(str)
            local mode_map = {
              ["NORMAL"] = "NORMAL",
              ["INSERT"] = "INSERCIÓN",
              ["VISUAL"] = "VISUAL",
              ["V-BLOCK"] = "VISUAL-B",
              ["REPLACE"] = "REEMPLAZO",
              ["COMMAND"] = "COMANDO",
              ["EX"] = "EX",
              ["SELECT"] = "SELECCIÓN",
              ["TERMINAL"] = "TERMINAL",
            }
            return mode_map[str] or str
          end,
        },
      },
      lualine_b = {
        "filename",
        { "filetype", icon_only = true },
      },
      lualine_c = {
        function()
          return vim.api.nvim_buf_line_count(0) .. "L"
        end,
      },
      lualine_x = {}, -- Espacio central
      lualine_y = {
        "", -- Arch Linux
        "󰂑", -- Batería (icono estático)
        "branch",
        { "fileformat", symbols = { unix = "󰘧", dos = "" } },
        "encoding",
      },
      lualine_z = {
        "location",
        "progress",
        function() end,
      },
    },
  },
}
