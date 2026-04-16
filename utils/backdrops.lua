---@type Wezterm
local wezterm = require('wezterm')
local colors = require('colors.custom')

-- Seeding random numbers before generating for use
-- Known issue with lua math library
-- see: https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
math.randomseed(os.time())
math.random()
math.random()
math.random()

local GLOB_PATTERN = '*.{jpg,jpeg,png,gif,bmp,ico,tiff,pnm,dds,tga}'

---@class BackDrops
---@field current_idx number index of current image
---@field images string[] background images
---@field images_dir string directory of background images. Default is `wezterm.config_dir .. '/backdrops/'`
---@field no_img boolean focus mode on or off
local BackDrops = {}
BackDrops.__index = BackDrops

--- Initialise backdrop controller
---@private
function BackDrops:init()
   local backdrops = {
      current_idx = 1,
      images = {},
      images_dir = wezterm.config_dir .. '/backdrops/',
      no_bg = false,
   }
   return setmetatable(backdrops, self)
end

---Override the default `images_dir`
---Default `images_dir` is `wezterm.config_dir .. '/backdrops/'`
---
--- INFO:
---  This function must be invoked before `scan_images_dir()`
---
---@param path string directory of background images
function BackDrops:set_images_dir(path)
   self.images_dir = path
   if not path:match('/$') then
      self.images_dir = path .. '/'
   end
   return self
end

---**MUST BE RUN BEFORE ALL OTHER `BackDrops` methods**
---Sets the `images` after instantiating `BackDrops`.
---
--- INFO:
---   During the initial load of the config, this function can only invoked in `wezterm.lua`.
---   WezTerm's fs utility `glob` (used in this function) works by running on a spawned child process.
---   This throws a coroutine error if the function is invoked in outside of `wezterm.lua` in the -
---   initial load of the Terminal config.
function BackDrops:scan_images_dir()
   self.images = wezterm.glob(self.images_dir .. GLOB_PATTERN)
   return self
end

---Create the `background` options with the current image
---@private
---@return BackgroundLayer[]
function BackDrops:_gen_opts()
   local bg_opts = {}

   if #self.images > 0 then
      table.insert(bg_opts, {
         source = { File = self.images[self.current_idx] },
         horizontal_align = 'Center',
      })
   end

   table.insert(bg_opts, {
      source = { Color = colors.background },
      height = '120%',
      width = '120%',
      vertical_offset = '-10%',
      horizontal_offset = '-10%',
      opacity = 0.96,
   })

   return bg_opts
end

---Create the `background` options for focus mode
---@private
---@return BackgroundLayer[]
function BackDrops:_gen_no_img_opts()
   return {
      {
         source = { Color = colors.background },
         height = '120%',
         width = '120%',
         vertical_offset = '-10%',
         horizontal_offset = '-10%',
         opacity = 1,
      },
   }
end

---Set the initial options for `background`
---@param opts {no_img?: boolean} initial options for `background`
function BackDrops:initial_options(opts)
   opts.no_img = opts.no_img or false
   assert(type(opts.no_img) == 'boolean', 'BackDrops:initial_options - Expected a boolean')

   self.no_img = opts.no_img
   if opts.no_img then
      return self:_gen_no_img_opts()
   end

   return self:_gen_opts()
end

---Override the current window options for background
---@private
---@param window Window WezTerm Window see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param background_opts BackgroundLayer[] background option
function BackDrops:_set_opt(window, background_opts)
   window:set_config_overrides({
      background = background_opts,
      enable_tab_bar = window:effective_config().enable_tab_bar,
   })
end

---Convert the `images` array to a table of `InputSelector` choices
---see: https://wezfurlong.org/wezterm/config/lua/keyassignment/InputSelector.html
function BackDrops:choices()
   local choices = {}
   for idx, file in ipairs(self.images) do
      table.insert(choices, {
         id = tostring(idx),
         label = file:match('([^/]+)$'),
      })
   end
   return choices
end

---Select a random background from the loaded `files`
---Pass in `Window` object to override the current window options
---@param window Window? WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:random(window)
   self.current_idx = math.random(#self.images)

   if window ~= nil then
      self:_set_opt(window, self:_gen_opts())
   end
end

---Cycle the loaded `files` and select the next background
---@param window Window WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_forward(window)
   if self.current_idx == #self.images then
      self.current_idx = 1
   else
      self.current_idx = self.current_idx + 1
   end
   self:_set_opt(window, self:_gen_opts())
end

---Cycle the loaded `files` and select the previous background
---@param window Window WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_back(window)
   if self.current_idx == 1 then
      self.current_idx = #self.images
   else
      self.current_idx = self.current_idx - 1
   end
   self:_set_opt(window, self:_gen_opts())
end

---Set a specific background from the `files` array
---@param window Window WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param idx number index of the `files` array
function BackDrops:set_img(window, idx)
   if idx > #self.images or idx < 0 then
      wezterm.log_error('Index out of range')
      return
   end

   self.current_idx = idx
   self:_set_opt(window, self:_gen_opts())
end

---Toggle the focus mode
---@param window Window WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:toggle_focus(window)
   local background_opts = self.no_img and self:_gen_opts() or self:_gen_no_img_opts()
   self.no_img = not self.no_img

   self:_set_opt(window, background_opts)
end

return BackDrops:init()
