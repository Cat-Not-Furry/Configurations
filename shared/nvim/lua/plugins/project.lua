return {
  "ahmedkhalf/project.nvim",
  event = "VeryLazy",
  config = function()
    require("project_nvim").setup({
      -- La detección es automática, pero puedes añadir patrones si lo necesitas
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
    })

    -- Se integra automáticamente con Telescope, ¡no necesitas hacer nada más!
  end,
}
