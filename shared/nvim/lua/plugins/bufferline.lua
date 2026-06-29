return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Fijar buffer" },
    { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Eliminar buffers no fijados" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Buffer siguiente" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Buffer anterior" },
  },
  opts = {
    options = {
      mode = "buffers", -- Muestra buffers en lugar de pestañas de nvim
      separator_style = "slant",
      show_buffer_close_icons = false,
      show_close_icon = false,
    },
  },
}
