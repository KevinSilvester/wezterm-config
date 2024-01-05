local wezterm = require('wezterm')
local colors = require('colors.custom')
-- local fonts = require('config.fonts')
local backgrounds_dir = wezterm.config_dir .. '/backdrops'
local backgrounds = {}
-- stores file values in array pipe
local pipe = io.popen(string.format('ls "%s"', backgrounds_dir))
-- creates a table of the backgrounds in the /backdrops directory
if pipe then
   local dir_contents = pipe:read('*a')
   if dir_contents then
      for file in dir_contents:gmatch('[^%\n]+') do
         table.insert(backgrounds, file)
      end
   end
   if not pipe:close() then
      print('Failed to close pipe')
   end
end
-- Selects a random value between min and max of backgrounds and stores the index return as the random_background at load
local random_index = math.random(#backgrounds)
local random_background = backgrounds[random_index]

return {
   animation_fps = 60,
   max_fps = 60,
   front_end = 'WebGpu',
   webgpu_power_preference = 'HighPerformance',

   -- color scheme
   colors = colors,

   -- background
   background = {
      {
         source = { File = backgrounds_dir .. '/' .. random_background },
      },
      {
         source = { Color = colors.background },
         height = '100%',
         width = '100%',
         opacity = 0.90,
      },
   },

   -- scrollbar
   enable_scroll_bar = true,

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
   window_close_confirmation = 'NeverPrompt',
   window_frame = {
      active_titlebar_bg = '#090909',
      -- font = fonts.font,
      -- font_size = fonts.font_size,
   },
   inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 },
}
