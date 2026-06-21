return {
  {
    "ojroques/nvim-osc52",
    event = "VeryLazy",
    cond = function()
      local backend = require("config.clipboard").detect()
      return backend ~= "wayland" and backend ~= "x11"
    end,
    config = function()
      local osc52 = require("osc52")

      osc52.setup({
        max_length = 0,
        silent = true,
        trim = false,
        tmux_passthrough = true,
      })

      vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("osc52_yank", { clear = true }),
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "" then
            osc52.copy(vim.fn.getreg(""))
          end
        end,
      })
    end,
  },
}
