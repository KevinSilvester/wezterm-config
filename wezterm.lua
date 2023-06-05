local Config = require('config')

require('events.right-status').setup()
require('events.tab-title').setup()

return Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domain'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch')).options
