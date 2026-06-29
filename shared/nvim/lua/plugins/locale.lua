return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader><tab>", group = "pestañas" },
        { "<leader>c", group = "código" },
        { "<leader>d", group = "depuración" },
        { "<leader>dp", group = "perfilador" },
        { "<leader>f", group = "archivo/buscar" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "fragmentos" },
        { "<leader>q", group = "salir/sesión" },
        { "<leader>s", group = "búsqueda" },
        { "<leader>sn", group = "noice" },
        { "<leader>u", group = "interfaz" },
        { "<leader>x", group = "diagnósticos/quickfix" },
        { "<leader>v", group = "imagen" },
        { "[", group = "anterior" },
        { "]", group = "siguiente" },
        { "g", group = "ir a" },
        { "gs", group = "rodear" },
        { "z", group = "plegado" },
        { "<leader>b", group = "buffers" },
        { "<leader>w", group = "ventanas" },
        { "gx", desc = "Abrir con app del sistema" },
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      require("config.locale").apply_dashboard(opts)
    end,
  },
}
