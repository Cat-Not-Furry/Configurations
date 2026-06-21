-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local terminal = require("config.terminal")

local function view_image_external()
  local file = vim.fn.expand("%:p")
  if file == "" or not terminal.is_image_file(file) then
    vim.notify("No es un archivo de imagen", vim.log.levels.WARN)
    return
  end

  local viewer = terminal.external_image_viewer()
  if not viewer then
    vim.notify("Instala feh (X11) o imv (Wayland)", vim.log.levels.ERROR)
    return
  end

  vim.system({ viewer, file }, { detach = true })
end

-- Fallback externo: feh en Alacritty/X11; imv en foot si hace falta
vim.keymap.set("n", "<leader>vi", view_image_external, { desc = "Ver imagen (visor externo)" })
