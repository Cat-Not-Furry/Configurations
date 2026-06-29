local M = {}

M.locale = "es_MX.UTF-8"
M.spelllang = "es"
M.keymap_desc = require("config.locale.keymaps_es")

function M.setup_env()
  if not vim.env.LANG or vim.env.LANG == "C" or vim.env.LANG == "" then
    vim.env.LANG = M.locale
  end
  if not vim.env.LC_MESSAGES or vim.env.LC_MESSAGES == "C" or vim.env.LC_MESSAGES == "" then
    vim.env.LC_MESSAGES = M.locale
  end
end

function M.setup_options()
  vim.opt.spelllang = { M.spelllang }
  vim.opt.helplang:append("es")

  pcall(vim.cmd, "language messages " .. M.locale)
  pcall(vim.cmd, "language ctype " .. M.locale)
  pcall(vim.cmd, "language time " .. M.locale)
end

function M.apply_dashboard(opts)
  require("config.locale.dashboard").apply(opts)
end

--- Traduce descripciones de atajos ya registrados.
function M.translate_keymaps()
  local translations = M.keymap_desc

  for _, mode in ipairs({ "n", "i", "v", "x", "s", "o", "t", "c" }) do
    local ok, keymaps = pcall(vim.keymap.get, { mode = mode })
    if not ok or not keymaps then
      goto continue
    end

    for _, km in ipairs(keymaps) do
      local desc = km.desc
      if desc and translations[desc] and desc ~= "which_key_ignore" then
        local lhs = km.lhs
        local rhs = km.callback or km.rhs
        if lhs and rhs then
          local opts = {}
          for k, v in pairs(km) do
            if k ~= "lhs" and k ~= "mode" and k ~= "rhs" and k ~= "callback" then
              opts[k] = v
            end
          end
          opts.desc = translations[desc]
          pcall(vim.keymap.del, mode, lhs, { buffer = km.buffer })
          pcall(vim.keymap.set, mode, lhs, rhs, opts)
        end
      end
    end

    ::continue::
  end
end

--- Reconfigura toggles de Snacks con nombres en español.
function M.setup_snacks_toggles()
  if not pcall(require, "snacks") then
    return
  end

  local Snacks = require("snacks")

  local toggles = {
    { "n", "<leader>us", Snacks.toggle.option("spell", { name = "Ortografía" }) },
    { "n", "<leader>uw", Snacks.toggle.option("wrap", { name = "Ajuste de línea" }) },
    { "n", "<leader>uL", Snacks.toggle.option("relativenumber", { name = "Números relativos" }) },
    { "n", "<leader>ud", Snacks.toggle.diagnostics({ name = "Diagnósticos" }) },
    { "n", "<leader>ul", Snacks.toggle.line_number({ name = "Números de línea" }) },
    {
      "n",
      "<leader>uc",
      Snacks.toggle.option("conceallevel", {
        off = 0,
        on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
        name = "Nivel de ocultamiento",
      }),
    },
    {
      "n",
      "<leader>uA",
      Snacks.toggle.option("showtabline", {
        off = 0,
        on = vim.o.showtabline > 0 and vim.o.showtabline or 2,
        name = "Barra de pestañas",
      }),
    },
    { "n", "<leader>uT", Snacks.toggle.treesitter({ name = "Treesitter" }) },
    {
      "n",
      "<leader>ub",
      Snacks.toggle.option("background", { off = "light", on = "dark", name = "Fondo oscuro" }),
    },
    { "n", "<leader>uD", Snacks.toggle.dim({ name = "Atenuar fondo" }) },
    { "n", "<leader>ua", Snacks.toggle.animate({ name = "Animaciones" }) },
    { "n", "<leader>ug", Snacks.toggle.indent({ name = "Indentación" }) },
    { "n", "<leader>uS", Snacks.toggle.scroll({ name = "Desplazamiento suave" }) },
    { "n", "<leader>uZ", Snacks.toggle.zoom({ name = "Zoom" }) },
    { "n", "<leader>uz", Snacks.toggle.zen({ name = "Modo zen" }) },
    { "n", "<leader>wm", Snacks.toggle.zoom({ name = "Zoom ventana" }) },
    { "n", "<leader>dpp", Snacks.toggle.profiler({ name = "Perfilador" }) },
    { "n", "<leader>dph", Snacks.toggle.profiler_highlights({ name = "Resaltado perfilador" }) },
  }

  if vim.lsp.inlay_hint then
    table.insert(toggles, { "n", "<leader>uh", Snacks.toggle.inlay_hints({ name = "Sugerencias inline" }) })
  end

  for _, item in ipairs(toggles) do
    local mode, key, toggle = item[1], item[2], item[3]
    if toggle then
      pcall(vim.keymap.del, mode, key)
      toggle:map(key)
    end
  end
end

function M.setup()
  M.setup_env()
  M.setup_options()
end

return M
