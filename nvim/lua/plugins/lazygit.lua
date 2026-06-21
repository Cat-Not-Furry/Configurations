return {
  "kdheepak/lazygit.nvim",
  -- Opcional: Esto añade la dependencia de lazygit.cmd
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  -- Configura un atajo de teclado para abrirlo
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit (dir. actual)" },
  },
}
