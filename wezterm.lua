local wezterm = require('wezterm')
local platform = require('utils.platform')
local Config = require('config')

require('events.right-status').setup()
require('events.tab-title').setup()

wezterm.GLOBAL.font = 'JetBrainsMono Nerd Font'
wezterm.GLOBAL.font_size = 9

if platform().is_mac then
   wezterm.GLOBAL.font_size = 12
end

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domain'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
