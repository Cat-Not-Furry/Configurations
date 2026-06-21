local M = {}

---@return "wayland"|"x11"|"ssh"|"none"
function M.detect()
  if os.getenv("WAYLAND_DISPLAY") and vim.fn.executable("wl-copy") == 1 then
    return "wayland"
  end
  if os.getenv("DISPLAY") and vim.fn.executable("xclip") == 1 then
    return "x11"
  end
  if os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY") then
    return "ssh"
  end
  return "none"
end

function M.setup()
  vim.opt.clipboard = "unnamedplus"

  local backend = M.detect()

  if backend == "wayland" then
    vim.g.clipboard = {
      name = "wl-clipboard",
      copy = {
        ["+"] = "wl-copy --type text/plain",
        ["*"] = "wl-copy --type text/plain --primary",
      },
      paste = {
        ["+"] = "wl-paste --no-newline",
        ["*"] = "wl-paste --no-newline --primary",
      },
      cache_enabled = 1,
    }
  elseif backend == "x11" then
    vim.g.clipboard = {
      name = "xclip",
      copy = {
        ["+"] = "xclip -selection clipboard -i",
        ["*"] = "xclip -selection primary -i",
      },
      paste = {
        ["+"] = "xclip -selection clipboard -o",
        ["*"] = "xclip -selection primary -o",
      },
      cache_enabled = 1,
    }
  elseif backend == "ssh" or backend == "none" then
    vim.schedule(function()
      if vim.fn.executable("wl-copy") == 0 and vim.fn.executable("xclip") == 0 then
        vim.notify(
          "Clipboard: sin wl-copy/xclip; se usará OSC52 si la terminal lo soporta",
          vim.log.levels.INFO
        )
      end
    end)
  end
end

return M
