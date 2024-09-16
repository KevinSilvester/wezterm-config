-- The only required line is this one.
local wezterm = require 'wezterm'
local Config = require('config')

return Config:init()
	:append(require('config.appearance')).options
