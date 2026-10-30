local wezterm = require('wezterm')
local platform = require('utils.platform')

local font_family = 'JetBrains Mono'
local font_size = platform.is_mac and 12 or 10

---@type Config
return {
   font = wezterm.font({ family = font_family, weight = 'Regular' }),
   font_size = font_size,

   freetype_load_target = 'Normal',
   freetype_render_target = 'Normal',
}
