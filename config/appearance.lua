local wezterm = require('wezterm')
local colors = require('themes.color')
local mux = wezterm.mux

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return {
   animation_fps = 60,
   max_fps = 60,

   -- color scheme
   colors = colors,

   -- tab
   enable_tab_bar = true,
   tab_bar_at_bottom = true,
   hide_tab_bar_if_only_one_tab = true,
   use_fancy_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

   -- window

   window_background_opacity = 0.7,
   window_decorations = "RESIZE",
   window_close_confirmation = 'NeverPrompt',

   inactive_pane_hsb = {
      saturation = 0.9,
      brightness = 0.65,
   },

   window_padding = {
      left = 60,
      right = 60,
      top = 20,
      bottom = 20,
   },

   native_macos_fullscreen_mode = true,
}
