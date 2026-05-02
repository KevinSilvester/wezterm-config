local wezterm = require('wezterm')
local platform = require('utils.platform')

---Backend options available based for the platforms.
---Higher the score, the better the backend (I think 🤷).
---See `https://github.com/gfx-rs/wgpu#supported-platforms` for more info on available backends
-- stylua: ignore
local AVAILABLE_BACKENDS = {
   windows = { Dx12   = 3, Vulkan = 2, Gl = 1 },
   linux   = { Vulkan = 2, Gl     = 1 },
   mac     = { Metal  = 1 },
}

---Device type options available.
---Higher the score, the better the device type.
-- stylua: ignore
local AVAILABLE_DEVICE_TYPES = {
   DiscreteGpu   = 4 * 100,
   IntegratedGpu = 3 * 100,
   Other         = 2 * 100,
   Cpu           = 1 * 100,
}

---@type GpuInfo[]
local ENUMERATED_GPUS = wezterm.gui.enumerate_gpus()

---@class GpuAdapters
---@field scoreboard {[number]: GpuInfo}
---@field best number
local GpuAdapters = {}
GpuAdapters.__index = GpuAdapters
GpuAdapters.backends = AVAILABLE_BACKENDS[platform.os]
GpuAdapters.device_types = AVAILABLE_DEVICE_TYPES

---@return GpuAdapters
---@private
function GpuAdapters:init()
   local initial = {
      scoreboard = {},
      best = 0,
   }

   -- iterate over the enumerated GPUs and create a `scoreboard` look-up-table
   -- where higher the score, the better the adapter
   for _, adapter in ipairs(ENUMERATED_GPUS) do
      local score = self.backends[adapter.backend] | self.device_types[adapter.device_type]
      if score > initial.best then
         initial.best = score
      end
      initial.scoreboard[score] = adapter
   end

   return setmetatable(initial, self)
end

---Will pick the best adapter based on the following criteria:
---   1. Best GPU available (Discrete > Integrated > Other (for wgpu's OpenGl implementation on Discrete GPU) > Cpu)
---   2. Best graphics API available (based off my very scientific scroll a big log file in neovim test 😁)
---
---Graphics API choices are based on the platform:
---   - Windows: Dx12 > Vulkan > OpenGl
---   - Linux: Vulkan > OpenGl
---   - Mac: Metal
---
---@see AVAILABLE_BACKENDS
---
---If the best adapter combo is not found, it will return `nil` and lets Wezterm decide the best adapter.
---
---Please note these are my own personal preferences and may not be the best for your system.
---If you want to manually choose the adapter, use `GpuAdapters:pick_manual(backend, device_type)`
---Or feel free to change the point allocated to the backends in `AVAILABLE_BACKENDS` to your liking.
---@return GpuInfo|nil
function GpuAdapters:pick_best()
   return self.best > 0 and self.scoreboard[self.best] or nil
end

---Manually pick the adapter based on the backend and device type.
---If the adapter is not found, it will return nil and lets Wezterm decide the best adapter.
---@param backend GpuInfo.Backend
---@param device_type GpuInfo.DeviceType
---@return GpuInfo|nil
function GpuAdapters:pick_manual(backend, device_type)
   local backend_score = self.backends[backend]
   local device_type_score = self.device_types[device_type]

   assert(backend_score, 'Invalid backend provided')
   assert(device_type_score, 'Invalid device type provided')

   local score = backend_score | device_type_score
   local adapter_choice = self.scoreboard[score]

   if not adapter_choice then
      wezterm.log_error('Preferred backend not available. Using Default Adapter.')
      return nil
   end

   return adapter_choice
end

return GpuAdapters:init()
