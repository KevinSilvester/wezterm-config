------------------------------------------------------------------------------------------
-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614 --
------------------------------------------------------------------------------------------

local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local GLYPH_SCIRCLE_LEFT = nf.ple_left_half_circle_thick --[[  ]]
local GLYPH_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[  ]]
local GLYPH_CIRCLE = nf.fa_circle --[[  ]]
local GLYPH_ADMIN = nf.md_shield_half_full --[[ 󰞀 ]]
local GLYPH_UBUNTU = nf.cod_terminal_linux --[[  ]]
local GLYPH_DEBUG = nf.fa_bug --[[  ]]

local TITLE_INSET = {
   DEFAULT = 6,
   ICON = 8,
}

local M = {}

local RENDER_VARIANTS = {
   { 'scircle_left', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'title', 'unseen_output', 'padding', 'scircle_right' },
   { 'scircle_left', 'admin', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'admin', 'title', 'unseen_output', 'padding', 'scircle_right' },
   { 'scircle_left', 'wsl', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'wsl', 'title', 'unseen_output', 'padding', 'scircle_right' },
}

-- stylua: ignore
local COLORS = {
   default              = { bg = '#45475A', fg = '#1C1B19' },
   default_hover        = { bg = '#587D8C', fg = '#1C1B19' },
   default_active       = { bg = '#7FB4CA', fg = '#11111B' },
   unseen_output        = { bg = '#45475A', fg = '#FFA066' },
   unseen_output_hover  = { bg = '#587D8C', fg = '#FFA066' },
   unseen_output_active = { bg = '#7FB4CA', fg = '#FFA066' },
   scircle              = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#45475A' },
   scircle_hover        = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#587D8C' },
   scircle_active       = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#7FB4CA' },
}

-- stylua: ignore
local SEGMENT_COLORS = {
   scircle       = { default = 'scircle', hover = 'scircle_hover', active = 'scircle_active', },
   text          = { default = 'default', hover = 'default_hover', active = 'default_active', },
   unseen_output = { default = 'unseen_output', hover = 'unseen_output_hover', active = 'unseen_output_active', },
}

---@param proc string
local function clean_process_name(proc)
   local a = string.gsub(proc, '(.*[/\\])(.*)', '%2')
   return a:gsub('%.exe$', '')
end

---@param process_name string
---@param base_title string
---@param max_width number
---@param inset number
local function create_title(process_name, base_title, max_width, inset)
   local title

   if process_name:len() > 0 then
      title = process_name .. ' ~ ' .. base_title
   else
      title = base_title
   end

   if base_title == 'Debug' then
      title = GLYPH_DEBUG .. ' DEBUG'
      inset = inset - 2
   end

   if title:len() > max_width - inset then
      local diff = title:len() - max_width + inset
      local max = title:len() - diff
      if #title > max then
         title = title:sub(1, max)
      end
   else
      local padding = max_width - title:len() - inset
      title = title .. string.rep(' ', padding)
   end

   return title
end

---@class Tab
---@field title string
---@field cells Cells
---@field title_locked boolean
---@field is_wsl boolean
---@field is_admin boolean
---@field unseen_output boolean
---@field is_active boolean
local Tab = {}
Tab.__index = Tab

function Tab:new()
   local tab = {
      title = '',
      cells = Cells:new(COLORS),
      title_locked = false,
      is_wsl = false,
      is_admin = false,
      unseen_output = false,
   }
   return setmetatable(tab, self)
end

---@param pane any WezTerm https://wezfurlong.org/wezterm/config/lua/pane/index.html
function Tab:set_info(pane, max_width)
   local process_name = clean_process_name(pane.foreground_process_name)
   self.is_wsl = process_name:match('^wsl') ~= nil
   self.is_admin = (pane.title:match('^Administrator: ') or pane.title:match('(Admin)')) ~= nil
   self.unseen_output = pane.has_unseen_output

   if self.title_locked then
      return
   end
   local inset = (self.is_admin or self.is_wsl) and TITLE_INSET.ICON or TITLE_INSET.DEFAULT
   if self.unseen_output then
      inset = inset + 2
   end
   self.title = create_title(process_name, pane.title, max_width, inset)
end

---@param is_active boolean
---@param hover boolean
function Tab:set_cells(is_active, hover)
   ---@type 'default'|'active'|'hover'
   local color_variant = 'default'
   if is_active then
      color_variant = 'active'
   elseif hover then
      color_variant = 'hover'
   end

   self.cells
      :push('scircle_left', GLYPH_SCIRCLE_LEFT, SEGMENT_COLORS['scircle'][color_variant])
      :push('admin', ' ' .. GLYPH_ADMIN, SEGMENT_COLORS['text'][color_variant])
      :push('wsl', ' ' .. GLYPH_UBUNTU, SEGMENT_COLORS['text'][color_variant])
      :push('title', ' ', SEGMENT_COLORS['text'][color_variant], attr(attr.intensity('Bold')))
      :push('unseen_output', ' ' .. GLYPH_CIRCLE, SEGMENT_COLORS['unseen_output'][color_variant])
      :push('padding', ' ', SEGMENT_COLORS['text'][color_variant])
      :push('scircle_right', GLYPH_SCIRCLE_RIGHT, SEGMENT_COLORS['scircle'][color_variant])
end

---@param title string
function Tab:update_and_lock_title(title)
   self.title = title
   self.title_locked = true
end

---@param is_active boolean
---@param hover boolean
function Tab:update_cells(is_active, hover)
   ---@type 'default'|'active'|'hover'
   local color_variant = 'default'
   if is_active then
      color_variant = 'active'
   elseif hover then
      color_variant = 'hover'
   end

   self.cells:update_segment_text('title', ' ' .. self.title)
   self.cells
      :update_segment_colors('scircle_left', SEGMENT_COLORS['scircle'][color_variant])
      :update_segment_colors('admin', SEGMENT_COLORS['text'][color_variant])
      :update_segment_colors('wsl', SEGMENT_COLORS['text'][color_variant])
      :update_segment_colors('title', SEGMENT_COLORS['text'][color_variant])
      :update_segment_colors('unseen_output', SEGMENT_COLORS['unseen_output'][color_variant])
      :update_segment_colors('padding', SEGMENT_COLORS['text'][color_variant])
      :update_segment_colors('scircle_right', SEGMENT_COLORS['scircle'][color_variant])
end

---@return FormatItem[] (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)
function Tab:render()
   local variant_idx = self.is_admin and 3 or 1
   if self.is_wsl then
      variant_idx = 5
   end

   if self.unseen_output then
      variant_idx = variant_idx + 1
   end
   return self.cells:render(RENDER_VARIANTS[variant_idx])
end

---@type Tab[]
local tab_list = {}

M.setup = function()
   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   -- Tab name will remain locked until the `reset-tab-title` is triggered
   wezterm.on('manual-update-tab-title', function(window, pane)
      window:perform_action(
         wezterm.action.PromptInputLine({
            description = wezterm.format({
               { Foreground = { Color = '#FFFFFF' } },
               { Attribute = { Intensity = 'Bold' } },
               { Text = 'Enter new name for tab' },
            }),
            action = wezterm.action_callback(function(_window, _pane, line)
               if line ~= nil then
                  local tab = window:active_tab()
                  local id = tab:tab_id()
                  tab_list[id]:update_and_lock_title(line)
               end
            end),
         }),
         pane
      )
   end)

   -- CUSTOM EVENT
   -- Event listener to unlock manually set tab name
   wezterm.on('reset-tab-title', function(window, _pane)
      local tab = window:active_tab()
      local id = tab:tab_id()
      tab_list[id].title_locked = false
   end)

   -- BUILTIN EVENT
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
      if not tab_list[tab.tab_id] then
         tab_list[tab.tab_id] = Tab:new()
         tab_list[tab.tab_id]:set_info(tab.active_pane, max_width)
         tab_list[tab.tab_id]:set_cells(tab.is_active, hover)
         return tab_list[tab.tab_id]:render()
      end

      tab_list[tab.tab_id]:set_info(tab.active_pane, max_width)
      tab_list[tab.tab_id]:update_cells(tab.is_active, hover)
      return tab_list[tab.tab_id]:render()
   end)
end

return M
