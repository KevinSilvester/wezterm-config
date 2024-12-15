local Config = require('config')

require('utils.backdrops')
   -- :set_focus('#000000')
   -- :set_images_dir(require('wezterm').home_dir .. '/Pictures/Wallpapers/')
   :set_images()
   :random()

require('events.right-status').setup()
require('events.left-status').setup()
require('events.tab-title').setup()
require('events.new-tab-button').setup()

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
