local wezterm = require('wezterm')

local platform = require('utils.platform')

local Config = require('config')
local appearance = require('config.appearance')
local bindings = require('config.bindings')
local domain = require('config.appearance')
local fonts = require('config.appearance')
local general = require('config.appearance')
local launch = require('config.launch')

require('events.right-status').setup()
require('events.tab-title').setup()

wezterm.GLOBAL.font = 'JetBrainsMono Nerd Font'
wezterm.GLOBAL.font_size = 9

if platform().is_mac then
   wezterm.GLOBAL.font_size = 12
end

return Config:init()
   :append(appearance)
   :append(bindings)
   :append(domain)
   :append(fonts)
   :append(general)
   :append(launch).options
