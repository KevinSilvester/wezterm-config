local wezterm = require('wezterm')
local platform = require('utils.platform')
local font
local font_size
local current_platform = platform()
if current_platform.is_mac then
   font = {
      'MesloLGS NF',
      'Apple Color Emoji',
   }
   font_size = 14
elseif current_platform.is_linux then
   font = 'MesloLGS Nerd Font'
   font_size = 17
elseif current_platform.is_win then
   font = 'CaskaydiaCove NF'
   font_size = 17
end

return {
   font = wezterm.font_with_fallback(font),
   font_size = font_size,

   --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
   freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
