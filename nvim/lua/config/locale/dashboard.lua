local M = {}

---@return snacks.dashboard.Item[]
function M.keys()
  return {
    { icon = " ", key = "f", desc = "Buscar archivo", action = ":lua Snacks.dashboard.pick('files')" },
    { icon = " ", key = "n", desc = "Archivo nuevo", action = ":ene | startinsert" },
    { icon = " ", key = "p", desc = "Proyectos", action = ":lua Snacks.picker.projects()" },
    { icon = " ", key = "g", desc = "Buscar texto", action = ":lua Snacks.dashboard.pick('live_grep')" },
    { icon = " ", key = "r", desc = "Archivos recientes", action = ":lua Snacks.dashboard.pick('oldfiles')" },
    {
      icon = " ",
      key = "c",
      desc = "Configuración",
      action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
    },
    { icon = " ", key = "s", desc = "Restaurar sesión", section = "session" },
    { icon = " ", key = "x", desc = "Extras de LazyVim", action = ":LazyExtras" },
    { icon = "󰒲 ", key = "l", desc = "Lazy (plugins)", action = ":Lazy" },
    { icon = " ", key = "q", desc = "Salir", action = ":qa" },
  }
end

function M.startup_section()
  return function()
    local stats = require("lazy.stats").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    return {
      align = "center",
      text = {
        { "⚡ Neovim cargó ", hl = "footer" },
        { stats.loaded .. "/" .. stats.count, hl = "special" },
        { " plugins en ", hl = "footer" },
        { ms .. "ms", hl = "special" },
      },
    }
  end
end

function M.apply(opts)
  opts.dashboard = opts.dashboard or {}
  opts.dashboard.preset = opts.dashboard.preset or {}
  opts.dashboard.preset.keys = M.keys()
  opts.dashboard.sections = {
    { section = "header" },
    { section = "keys", gap = 1, padding = 1 },
    M.startup_section(),
  }
end

return M
