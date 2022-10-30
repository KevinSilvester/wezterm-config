local wezterm = require("wezterm")
local custom = require("colors.custom")
local keybindings = require("config.key-bindings")
local launch_menu = require("config.launch-menu")
local ssh_domains = require("config.ssh-domains")
local shell = require("config.shell")
require("config.right-status").setup()
require("config.notify").setup()
require("config.tab-title").setup()

local font_primary = "JetBrainsMono NF"

local function font(name, params)
   return wezterm.font(name, params)
end

-- [[ font with fallback ]]
-- local function font_with_fallback(name, params)
--   local names = { name }
--   return wezterm.font_with_fallback(names, params)
-- end

return {
   -- fonts
   font = font(font_primary),
   font_size = 9,

   -- colour scheme
   colors = custom,

   -- background
   background = {
      {
         source = { File = wezterm.config_dir .. "/backdrops/space.jpg" },
      },
      {
         source = { Color = custom.background },
         height = "100%",
         width = "100%",
         opacity = 0.90,
      },
   },

   -- scroll bar
   enable_scroll_bar = true,

   -- status
   status_update_interval = 1000,

   -- tab bar
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = false,
   use_fancy_tab_bar = false,
   tab_max_width = 25,
   show_tab_index_in_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

   -- window
   window_padding = {
      left = 5,
      right = 10,
      top = 12,
      bottom = 7,
   },
   window_close_confirmation = "NeverPrompt",
   window_frame = {
      active_titlebar_bg = "#090909",
      font = font(font_primary, { bold = true }),
      font_size = 9,
   },
   automatically_reload_config = true,
   inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 },
   -- window_background_opacity = 0.9,

   -- keybindings
   disable_default_key_bindings = true,
   keys = keybindings,

   -- mousebindings
   mouse_bindings = {
      -- Ctrl-click will open the link under the mouse cursor
      {
         event = { Up = { streak = 1, button = "Left" } },
         mods = "CTRL",
         action = wezterm.action.OpenLinkAtMouseCursor,
      },
   },

   -- shells
   default_prog = shell,
   launch_menu = launch_menu,

   -- ssh
   ssh_domains = ssh_domains,

   -- wsl
   wsl_domains = {
      {
         name = "WSL:Ubuntu",
         distribution = "Ubuntu",
         username = "kevin",
         default_cwd = "/home/kevin",
         default_prog = { "fish" },
      },
   },
}
