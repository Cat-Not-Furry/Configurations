--- Tema Hyprland: lee theme.generated.lua (apply-theme.sh) y aplica tokyonight.
local M = {}

local GENERATED = vim.fn.stdpath("config") .. "/lua/config/theme.generated.lua"
local _last_mtime = 0

local function waybar_on_colors(wb)
	return function(colors)
		colors.bg = wb.background or colors.bg
		colors.bg_dark = wb.background or colors.bg_dark
		colors.bg_float = wb.background or colors.bg_float
		colors.bg_sidebar = wb.background or colors.bg_sidebar
		colors.bg_statusline = wb.background or colors.bg_statusline
		colors.fg = wb.foreground or colors.fg
		colors.fg_dark = wb.foreground or colors.fg_dark
		colors.fg_gutter = wb.foreground or colors.fg_gutter
		colors.blue = wb.accent or colors.blue
		colors.cyan = wb.accent_light or colors.cyan
		colors.red = wb.urgent or colors.red
		colors.yellow = wb.warning or colors.yellow
		colors.magenta = wb.critical or colors.magenta
		colors.green = wb.media_playing or colors.green
		colors.orange = wb.media_paused or colors.orange
		colors.border = wb.accent or colors.border
	end
end

function M.load()
	local ok, cfg = pcall(dofile, GENERATED)
	if not ok or type(cfg) ~= "table" then
		return nil
	end
	return cfg
end

function M.tokyonight_opts(cfg)
	cfg = cfg or M.load()
	if not cfg then
		return { style = "night" }
	end

	local style = cfg.style or "night"
	local on_colors = nil

	if cfg.mode == "custom" and cfg.waybar then
		on_colors = waybar_on_colors(cfg.waybar)
	elseif cfg.mode == "preset" and cfg.preset then
		package.loaded["config.themes." .. cfg.preset:gsub("-", "_")] = nil
		local mod = "config.themes." .. cfg.preset:gsub("-", "_")
		local preset_ok, preset = pcall(require, mod)
		if preset_ok and type(preset) == "table" then
			style = preset.style or style
			if preset.colors then
				local fixed = preset.colors
				on_colors = function(colors)
					for k, v in pairs(fixed) do
						colors[k] = v
					end
				end
			end
		end
		if cfg.waybar and not on_colors then
			on_colors = waybar_on_colors(cfg.waybar)
		elseif cfg.waybar and on_colors then
			local base = on_colors
			local wb_fn = waybar_on_colors(cfg.waybar)
			on_colors = function(colors)
				base(colors)
				wb_fn(colors)
			end
		end
	else
		return { style = "night" }
	end

	return {
		style = style,
		transparent = false,
		on_colors = on_colors,
	}
end

function M.apply()
	local cfg = M.load()
	if not cfg then
		vim.notify("hypr-theme: no se encontró theme.generated.lua", vim.log.levels.WARN)
		return
	end

	require("tokyonight").setup(M.tokyonight_opts(cfg))
	vim.cmd.colorscheme(cfg.colorscheme or "tokyonight")

	if package.loaded["lualine"] then
		require("lualine").setup(require("lualine").get_config())
	end

	local stat = vim.uv.fs_stat(GENERATED)
	if stat then
		_last_mtime = stat.mtime.sec
	end
end

function M.apply_if_changed()
	local stat = vim.uv.fs_stat(GENERATED)
	if not stat then
		return
	end
	if stat.mtime.sec ~= _last_mtime then
		M.apply()
	end
end

function M.setup_autocmds()
	vim.api.nvim_create_user_command("HyprThemeReload", function()
		M.apply()
	end, { desc = "Reaplicar tema Hyprland (theme.generated.lua)" })

	vim.api.nvim_create_autocmd("FocusGained", {
		callback = function()
			M.apply_if_changed()
		end,
	})
end

return M
