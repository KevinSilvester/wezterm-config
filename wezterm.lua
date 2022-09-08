local wezterm = require("wezterm")
local catppuccin = require("colors.catppuccin").setup({ flavour = "mocha" })
local lume = require("utils.lume")

local keybindings = require("config.key-bindings")
local launch_menu = require("config.launch-menu")
local ssh_domains = require("config.ssh-domains")
local shell = require("config.shell")
require("config.right-status").setup()
require("config.notify").setup()

local font_name = "JetBrainsMono NF"

local function font(name, params)
	return wezterm.font(name, params)
end

return {
	-- fonts
	font = font(font_name),
	font_size = 9,

	-- colour scheme
	colors = catppuccin,

	-- scroll bar
	enable_scroll_bar = true,

	-- status
	status_update_interval = 1000,

	-- tab bar
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	tab_max_width = 20,
	show_tab_index_in_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

	-- window
	window_padding = {
		left = 5,
		right = 10,
		top = 12,
		bottom = 12,
	},
	automatically_reload_config = true,
	inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 },
	window_background_opacity = 1.0,
	window_close_confirmation = "NeverPrompt",
	window_frame = {
		active_titlebar_bg = "#090909",
		font = font(font_name, { bold = true }),
		font_size = 9,
	},

	-- keybindings
	disable_default_key_bindings = true,
	keys = keybindings,

	-- shells
	default_prog = { shell },
	-- add_wsl_distributions_to_launch_menu = false,
	launch_menu = launch_menu,
   
   -- ssh
   ssh_domains = ssh_domains,


	-- wls_domains = {
	-- 	{
	-- 		name = "WSL:Ubuntu",
	-- 		distribution = "Ubuntu",
	-- 		username = "kevin",
	-- 		default_cwd = "/home/kevin"
	-- 	},
	-- },
}
