local M = {}

---@return string
function M.term()
  return vim.env.TERM or ""
end

function M.is_foot()
  return M.term():match("^foot") ~= nil
end

function M.is_alacritty()
  return M.term():match("alacritty") ~= nil
end

function M.supports_sixel()
  return M.is_foot()
end

--- Visor externo: feh en X11/Alacritty; imv en Wayland si hace falta.
---@return string|nil comando ejecutable
function M.external_image_viewer()
  if M.is_alacritty() or (os.getenv("DISPLAY") and not os.getenv("WAYLAND_DISPLAY")) then
    if vim.fn.executable("feh") == 1 then
      return "feh"
    end
  end
  if M.is_foot() and vim.fn.executable("imv") == 1 then
    return "imv"
  end
  return nil
end

---@param path string
---@return boolean
function M.is_image_file(path)
  return path:match("%.(png|jpe?g|gif|webp|bmp|svg|tiff?)$") ~= nil
end

return M
