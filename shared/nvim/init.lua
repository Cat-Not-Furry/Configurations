-- Locale es-MX antes de cargar plugins
require("config.locale").setup_env()

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("config.hypr-theme").setup_autocmds()
