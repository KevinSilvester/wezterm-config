local wezterm = require('wezterm')
local colors = require('colors.custom')

-- Seeding random numbers before generating for use
-- Known issue with lua math library
-- see: https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
math.randomseed(os.time())
math.random()
math.random()
math.random()

---@class BackDrops
---@field current_idx number index of current image
---@field files string[] background images
local BackDrops = {}

--- Initialise backdrop controller
---@private
function BackDrops:init()
   self.__index = self
   local inital = {
      current_idx = 1,
      files = {},
   }
   local backdrops = setmetatable(inital, self)
   return backdrops
end

---MUST BE RUN BEFORE ALL OTHER `BackDrops` functions
---Workaround to set the `files` after instantiating `BackDrops`.
---WezTerm's fs utilities `read_dir` and `glob` work by running on a spawned child process.
---This throw a coroutine error if either of the functions are invoked in outside of `wezterm.lua`
---in the initial load of the Terminal config
function BackDrops:set_files()
   self.files = wezterm.read_dir(wezterm.config_dir .. '/backdrops')
   return self
end

---Override the current window options for background
---@private
---@param window any WezTerm Window see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:set_opt(window)
   local opts = {
      background = {
         {
            source = { File = wezterm.GLOBAL.background },
         },
         {
            source = { Color = colors.background },
            height = '100%',
            width = '100%',
            opacity = 0.90,
         },
      },
   }
   window:set_config_overrides(opts)
end

---MUST BE RUN BEFORE APPEARANCE OPTIONS ARE SET
---Select a random file and redefine the global `wezterm.GLOBAL.background` variable
---Pass in `Window` object to override the background options to apply change
---@param window any? WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:random(window)
   self.current_idx = math.random(#self.files)
   wezterm.GLOBAL.background = self.files[self.current_idx]

   if window ~= nil then
      self:set_opt(window)
   end
end

---Cycle the loaded `files` and select the next background
---@param window any? WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_forward(window)
   if self.current_idx == #self.files then
      self.current_idx = 1
   else
      self.current_idx = self.current_idx + 1
   end
   wezterm.GLOBAL.background = self.files[self.current_idx]
   self:set_opt(window)
end

---Cycle the loaded `files` and select the next background
---@param window any? WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_back(window)
   if self.current_idx == 1 then
      self.current_idx = #self.files
   else
      self.current_idx = self.current_idx - 1
   end
   wezterm.GLOBAL.background = self.files[self.current_idx]
   self:set_opt(window)
end

return BackDrops:init()
