local wezterm = require('wezterm')
local platform = require('utils.platform')

---@alias WeztermGPUBackend 'Vulkan'|'Metal'|'Gl'|'Dx12'
---@alias WeztermGPUDeviceType 'DiscreteGpu'|'IntegratedGpu'|'Cpu'|'Other'

---@class WeztermGPUAdapter
---@field name string
---@field backend WeztermGPUBackend
---@field device number
---@field device_type WeztermGPUDeviceType
---@field driver? string
---@field driver_info? string
---@field vendor string

---@alias AdapterMap { [WeztermGPUBackend]: WeztermGPUAdapter|nil }|nil

---@class GpuAdapters
---@field __backends WeztermGPUBackend[]
---@field __preferred_backend WeztermGPUBackend
---@field DiscreteGpu AdapterMap
---@field IntegratedGpu AdapterMap
---@field Cpu AdapterMap
---@field Other AdapterMap
local GpuAdapters = {}
GpuAdapters.__index = GpuAdapters

---See `https://github.com/gfx-rs/wgpu#supported-platforms` for more info on available backends
GpuAdapters.AVAILABLE_BACKENDS = {
   windows = { 'Dx12', 'Vulkan', 'Gl' },
   linux = { 'Vulkan', 'Gl' },
   mac = { 'Metal' },
}

---@type WeztermGPUAdapter[]
GpuAdapters.ENUMERATED_GPUS = wezterm.gui.enumerate_gpus()

---@return GpuAdapters
---@private
function GpuAdapters:init()
   local initial = {
      __backends = self.AVAILABLE_BACKENDS[platform.os],
      __preferred_backend = self.AVAILABLE_BACKENDS[platform.os][1],
      DiscreteGpu = nil,
      IntegratedGpu = nil,
      Cpu = nil,
      Other = nil,
   }

   -- iterate over the enumerated GPUs and create a lookup table (`AdapterMap`)
   for _, adapter in ipairs(self.ENUMERATED_GPUS) do
      if not initial[adapter.device_type] then
         initial[adapter.device_type] = {}
      end
      initial[adapter.device_type][adapter.backend] = adapter
   end

   local gpu_adapters = setmetatable(initial, self)

   return gpu_adapters
end

---Will pick the best adapter based on the following criteria:
---   1. Best GPU available (Discrete > Integrated > Other (for wgpu's OpenGl implementation on Discrete GPU) > Cpu)
---   2. Best graphics API available (based off my very scientific scroll a big log file in neovim test 😁)
---
---Graphics API choices are based on the platform:
---   - Windows: Dx12 > Vulkan > OpenGl
---   - Linux: Vulkan > OpenGl
---   - Mac: Metal
---@see GpuAdapters.AVAILABLE_BACKENDS
---
---If the best adapter combo is not found, it will return `nil` and lets Wezterm decide the best adapter.
---
---Please note these are my own personal preferences and may not be the best for your system.
---If you want to manually choose the adapter, use `GpuAdapters:pick_manual(backend, device_type)`
---Or feel free to re-arrange `GpuAdapters.AVAILABLE_BACKENDS` to you liking
---@return WeztermGPUAdapter|nil
function GpuAdapters:pick_best()
   local adapters_options = self.DiscreteGpu
   local preferred_backend = self.__preferred_backend

   if not adapters_options then
      adapters_options = self.IntegratedGpu
   end

   if not adapters_options then
      adapters_options = self.Other
      preferred_backend = 'Gl'
   end

   if not adapters_options then
      adapters_options = self.Cpu
   end

   if not adapters_options then
      wezterm.log_error('No GPU adapters found. Using Default Adapter.')
      return nil
   end

   local adapter_choice = adapters_options[preferred_backend]

   if not adapter_choice then
      wezterm.log_error('Preferred backend not available. Using Default Adapter.')
      return nil
   end

   return adapter_choice
end

---Manually pick the adapter based on the backend and device type.
---If the adapter is not found, it will return nil and lets Wezterm decide the best adapter.
---@param backend WeztermGPUBackend
---@param device_type WeztermGPUDeviceType
---@return WeztermGPUAdapter|nil
function GpuAdapters:pick_manual(backend, device_type)
   local adapters_options = self[device_type]

   if not adapters_options then
      wezterm.log_error('No GPU adapters found. Using Default Adapter.')
      return nil
   end

   local adapter_choice = adapters_options[backend]

   if not adapter_choice then
      wezterm.log_error('Preferred backend not available. Using Default Adapter.')
      return nil
   end

   return adapter_choice
end

return GpuAdapters:init()
