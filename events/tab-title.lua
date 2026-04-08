------------------------------------------------------------------------------------------
-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614 --
------------------------------------------------------------------------------------------

---@type Wezterm
local wezterm = require('wezterm')
local Cells = require('utils.cells')
local OptsValidator = require('utils.opts-validator')
local ustr = require('utils.str')
local umath = require('utils.math')

local nf = wezterm.nerdfonts
local attr = Cells.attr

---
-- =======================================
-- Defining event setup options and schema
-- =======================================

---@class Event.TabTitleOptionsInput
---@field unseen_icon? 'circle' | 'numbered_circle' | 'numbered_box'
---@field hide_active_tab_unseen? boolean
---@field show_progress? boolean

---@class Event.TabTitleOptions
---@field unseen_icon 'circle' | 'numbered_circle' | 'numbered_box'
---@field hide_active_tab_unseen boolean
---@field show_progress boolean

---Setup options for the tab title
---@type OptsValidator
local EVENT_OPTS = OptsValidator:new({
   {
      name = 'unseen_icon',
      type = 'string',
      enum = { 'circle', 'numbered_circle', 'numbered_box' },
      default = 'circle',
   },
   {
      name = 'hide_active_tab_unseen',
      type = 'boolean',
      default = true,
   },
   {
      name = 'show_progress',
      type = 'boolean',
      default = true,
   },
})

---
-- ===================
-- Constants and icons
-- ===================

local M = {}

local ICON_SCIRCLE_LEFT = nf.ple_left_half_circle_thick --[[  ]]
local ICON_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[  ]]

-- stylua: ignore
---@enum PrefixIcon
local ICON_PREFIX = {
   admin = nf.md_shield_half_full,  --[[ 󰞀 ]]
   wsl = nf.cod_terminal_linux,     --[[  ]]
   debug = nf.fa_bug,               --[[  ]]
   select = nf.md_selection_search, --[[ 󱈅 ]]
   --  search = '🔭',
   launcher = nf.oct_rocket,        --[[  ]]
   edit = nf.fa_edit,               --[[  ]]
}

---@enum UnseenOutputIcon
local ICON_UNSEEN = {
   cirlce = nf.fa_circle, --[[  ]]

   numbered_box_1 = nf.md_numeric_1_box_multiple, --[[ 󰼏 ]]
   numbered_box_2 = nf.md_numeric_2_box_multiple, --[[ 󰼐 ]]
   numbered_box_3 = nf.md_numeric_3_box_multiple, --[[ 󰼑 ]]
   numbered_box_4 = nf.md_numeric_4_box_multiple, --[[ 󰼒 ]]
   numbered_box_5 = nf.md_numeric_5_box_multiple, --[[ 󰼓 ]]
   numbered_box_6 = nf.md_numeric_6_box_multiple, --[[ 󰼔 ]]
   numbered_box_7 = nf.md_numeric_7_box_multiple, --[[ 󰼕 ]]
   numbered_box_8 = nf.md_numeric_8_box_multiple, --[[ 󰼖 ]]
   numbered_box_9 = nf.md_numeric_9_box_multiple, --[[ 󰼗 ]]
   numbered_box_10 = nf.md_numeric_9_plus_box_multiple, --[[ 󰼘 ]]

   numbered_circle_1 = nf.md_numeric_1_circle, --[[ 󰲠 ]]
   numbered_circle_2 = nf.md_numeric_2_circle, --[[ 󰲢 ]]
   numbered_circle_3 = nf.md_numeric_3_circle, --[[ 󰲤 ]]
   numbered_circle_4 = nf.md_numeric_4_circle, --[[ 󰲦 ]]
   numbered_circle_5 = nf.md_numeric_5_circle, --[[ 󰲨 ]]
   numbered_circle_6 = nf.md_numeric_6_circle, --[[ 󰲪 ]]
   numbered_circle_7 = nf.md_numeric_7_circle, --[[ 󰲬 ]]
   numbered_circle_8 = nf.md_numeric_8_circle, --[[ 󰲮 ]]
   numbered_circle_9 = nf.md_numeric_9_circle, --[[ 󰲰 ]]
   numbered_circle_10 = nf.md_numeric_9_plus_circle, --[[ 󰲲 ]]
}

local ICON_PROGRESS_PCT_FRAMES = {
   [1] = nf.md_circle_slice_1, --[[ 󰪞 ]]
   [2] = nf.md_circle_slice_2, --[[ 󰪟 ]]
   [3] = nf.md_circle_slice_3, --[[ 󰪠 ]]
   [4] = nf.md_circle_slice_4, --[[ 󰪡 ]]
   [5] = nf.md_circle_slice_5, --[[ 󰪢 ]]
   [6] = nf.md_circle_slice_6, --[[ 󰪣 ]]
   [7] = nf.md_circle_slice_7, --[[ 󰪤 ]]
   [8] = nf.md_circle_slice_8, --[[ 󰪥 ]]
}

-- stylua: ignore
local ICON_PROGRESS_IND_FRAMES = {
   [1] = nf.fa_hourglass_start, --[[  ]]
   [2] = nf.fa_hourglass_end,   --[[  ]]
   [3] = nf.fa_hourglass_half,  --[[  ]]
}

local TITLE_INSET = {
   default = 4,
   increment = 2,
}

-- stylua: ignore
---Render Segments
local RS = {
   scircle_left  = 1,
   icon          = 2,
   title         = 3,
   progress      = 4,
   unseen_output = 5,
   padding       = 6,
   scircle_right = 7,
}

-- stylua: ignore
-- luacheck: ignore
---Render Variants
local RV = {
   { RS.scircle_left, RS.padding, RS.title, RS.padding, RS.scircle_right },
   { RS.scircle_left, RS.padding, RS.title, RS.padding, RS.unseen_output, RS.padding, RS.scircle_right },

   { RS.scircle_left, RS.padding, RS.title, RS.padding, RS.progress, RS.padding, RS.scircle_right },
   { RS.scircle_left, RS.padding, RS.title, RS.padding, RS.progress, RS.padding, RS.unseen_output, RS.padding, RS.scircle_right },

   { RS.scircle_left, RS.padding, RS.icon, RS.padding, RS.title, RS.padding, RS.scircle_right },
   { RS.scircle_left, RS.padding, RS.icon, RS.padding, RS.title, RS.padding, RS.unseen_output, RS.padding, RS.scircle_right },

   { RS.scircle_left, RS.padding, RS.icon, RS.padding, RS.title, RS.padding, RS.progress, RS.padding, RS.scircle_right },
   { RS.scircle_left, RS.padding, RS.icon, RS.padding, RS.title, RS.padding, RS.progress, RS.padding, RS.unseen_output, RS.padding, RS.scircle_right },
}


---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
   text_default          = { bg = '#45475A', fg = '#1C1B19' },
   text_hover            = { bg = '#7188b0', fg = '#1C1B19' },
   text_active           = { bg = '#89b4fa', fg = '#11111B' },

   unseen_output_default = { bg = '#45475A', fg = '#FFA066' },
   unseen_output_hover   = { bg = '#7188b0', fg = '#FFA066' },
   unseen_output_active  = { bg = '#89b4fa', fg = '#FFA066' },

   scircle_default       = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#45475A' },
   scircle_hover         = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#7188b0' },
   scircle_active        = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#89b4fa' },

   progress_percentage_default    = { bg = '#45475A', fg = '#9df296' },
   progress_percentage_hover      = { bg = '#7188b0', fg = '#9df296' },
   progress_percentage_active     = { bg = '#89b4fa', fg = '#9df296' },

   progress_error_default         = { bg = '#45475A', fg = '#fa3970' },
   progress_error_hover           = { bg = '#7188b0', fg = '#fa3970' },
   progress_error_active          = { bg = '#89b4fa', fg = '#fa3970' },

   progress_indeterminate_default = { bg = '#45475A', fg = '#f5e0dc' },
   progress_indeterminate_hover   = { bg = '#7188b0', fg = '#f5e0dc' },
   progress_indeterminate_active  = { bg = '#89b4fa', fg = '#f5e0dc' },
}

---
-- ================
-- Helper functions
-- ================

---@param pct number
local function _pct_to_frame(pct)
   local frame = math.floor(pct * #ICON_PROGRESS_PCT_FRAMES / 100)
   return ICON_PROGRESS_PCT_FRAMES[frame]
end

local __indeter_frame = 1
local function _ind_to_frame()
   local frame = __indeter_frame
   __indeter_frame = (__indeter_frame % #ICON_PROGRESS_IND_FRAMES) + 1
   return ICON_PROGRESS_IND_FRAMES[frame]
end

---@param proc string
local function clean_process_name(proc)
   local a = string.gsub(proc, '.*[/\\](.*)', '%1')
   return a:gsub('%.exe$', '')
end

---@generic T
---@param pane_title string
---@param process_name string
---@return string, PrefixIcon?
local function create_base_title(pane_title, process_name)
   ---@type PrefixIcon|nil
   local prefix_icon = nil
   local base_title = pane_title

   if ustr.starts_with(base_title, 'Administrator:') or ustr.ends_with(base_title, '(Admin)') then
      prefix_icon = ICON_PREFIX.admin
      base_title = base_title:gsub('Administrator: ', ''):gsub('%(Admin%)', '')
   end

   if ustr.starts_with(process_name, 'wsl') then
      prefix_icon = ICON_PREFIX.wsl
   end

   -- if Debug-Overlay is active
   if base_title == 'Debug' then
      prefix_icon = ICON_PREFIX.debug
      base_title = base_title:upper()
   end

   -- if built-in Launcher is active
   if base_title == 'Launcher' then
      prefix_icon = ICON_PREFIX.launcher
      base_title = base_title:upper()
   end

   if ustr.starts_with(base_title, 'InputSelector:') then
      prefix_icon = ICON_PREFIX.select
      base_title = base_title:gsub('InputSelector: ', '')
   end

   return base_title, prefix_icon
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

   if title:len() > max_width - inset then
      local diff = title:len() - max_width + inset
      title = title:sub(1, title:len() - diff)
   else
      local padding = max_width - title:len() - inset
      title = title .. string.rep(' ', padding)
   end

   return title
end

---@param options Event.TabTitleOptions
---@param progress PaneProgress
---@return string?, 'percentage' | 'error' | 'indeterminate' | nil
local function check_progress(options, progress)
   if not options.show_progress then
      return nil, nil
   end

   local icon = nil
   local status = nil

   if progress == 'Indeterminate' then
      status = 'indeterminate'
      icon = _ind_to_frame()
   elseif progress.Percentage ~= nil then
      status = 'percentage'
      icon = _pct_to_frame(progress.Percentage)
   elseif progress.Error ~= nil then
      status = 'error'
      icon = _pct_to_frame(progress.Error)
   end

   return icon, status
end

---@param options Event.TabTitleOptions
---@param is_active boolean
---@param panes PaneInformation[] WezTerm https://wezfurlong.org/wezterm/config/lua/pane/index.html
---@return UnseenOutputIcon|nil
local function check_unseen_output(options, is_active, panes)
   if options.hide_active_tab_unseen and is_active then
      return nil
   end

   local icon = nil

   local count = 0
   local limit = 10

   if options.unseen_icon == 'circle' then
      limit = 0
   end

   for i = 1, #panes, 1 do
      if count > limit then
         break
      end

      if panes[i].has_unseen_output then
         count = count + 1
      end
   end

   if count > 0 then
      if options.unseen_icon == 'circle' then
         icon = ICON_UNSEEN[options.unseen_icon]
      else
         icon = ICON_UNSEEN[options.unseen_icon .. '_' .. count]
      end
   end

   return icon
end

---
-- =================
-- Tab class and API
-- =================

---@class Tab
---@field cells FormatCells
---@field title_locked boolean
---@field locked_title string
---@field has_icon boolean
---@field has_unseen boolean
---@field has_progress boolean
local Tab = {}
Tab.__index = Tab

function Tab:new()
   local cells = Cells:new()
      :add_segment(RS.scircle_left, ICON_SCIRCLE_LEFT)
      :add_segment(RS.icon, '')
      :add_segment(RS.title, '', nil, attr(attr.intensity('Bold')))
      :add_segment(RS.progress, '')
      :add_segment(RS.unseen_output, '')
      :add_segment(RS.padding, ' ')
      :add_segment(RS.scircle_right, ICON_SCIRCLE_RIGHT)

   ---@type Tab
   local tab = {
      cells = cells,
      title_locked = false,
      locked_title = '',
      has_icon = false,
      has_unseen = false,
      has_progress = false,
   }

   return setmetatable(tab, self)
end

---@param event_opts Event.TabTitleOptions
---@param tab TabInformation WezTerm https://wezfurlong.org/wezterm/config/lua/MuxTab/index.html
---@param hover boolean
---@param max_width number
function Tab:update_cells(event_opts, tab, hover, max_width)
   self.has_icon = false
   self.has_unseen = false
   self.has_progress = false

   local tab_state = 'default'
   if tab.is_active then
      tab_state = 'active'
   elseif hover then
      tab_state = 'hover'
   end

   local process_name = clean_process_name(tab.active_pane.foreground_process_name)
   local base_title, prefix_icon = create_base_title(tab.active_pane.title, process_name)
   local unseen_icon = check_unseen_output(event_opts, tab.is_active, tab.panes)
   local progress_icon, progress_status = check_progress(event_opts, tab.active_pane.progress)
   local inset = TITLE_INSET.default

   if prefix_icon then
      inset = inset + TITLE_INSET.increment
      self.has_icon = true
      self.cells:update_segment_text(RS.icon, prefix_icon)
   end

   if unseen_icon then
      inset = inset + TITLE_INSET.increment
      self.has_unseen = true
      self.cells:update_segment_text(RS.unseen_output, unseen_icon)
   end

   if progress_icon and progress_status then
      inset = inset + TITLE_INSET.increment
      self.has_progress = true
      self.cells:update_segment_text(RS.progress, progress_icon)
      self.cells:update_segment_colors(
         RS.progress,
         colors['progress_' .. progress_status .. '_' .. tab_state]
      )
   end

   if self.title_locked then
      process_name = ''
      base_title = self.locked_title
   end

   local title = create_title(process_name, base_title, max_width, inset)

   self.cells:update_segment_text(RS.title, title)

   -- stylua: ignore
   self.cells
      :update_segment_colors(RS.scircle_left,   colors['scircle_' .. tab_state])
      :update_segment_colors(RS.icon,           colors['text_' .. tab_state])
      :update_segment_colors(RS.title,          colors['text_' .. tab_state])
      :update_segment_colors(RS.unseen_output,  colors['unseen_output_' .. tab_state])
      :update_segment_colors(RS.padding,        colors['text_' .. tab_state])
      :update_segment_colors(RS.scircle_right,  colors['scircle_' .. tab_state])
end

---@param title string
function Tab:update_and_lock_title(title)
   self.locked_title = title
   self.title_locked = true
end

---@return FormatItem[] (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)
function Tab:render()
   local variant_idx = self.has_icon and 5 or 1
   if self.has_unseen then
      variant_idx = variant_idx + 1
   end
   if self.has_progress then
      variant_idx = variant_idx + 2
   end
   return self.cells:render(RV[variant_idx])
end

---@type Tab[]
local tab_list = {}

---@param opts? Event.TabTitleOptionsInput Default: {unseen_icon = 'circle', hide_active_tab_unseen = true, show_progress = true}
M.setup = function(opts)
   local valid_opts, err = EVENT_OPTS:validate(opts or {})

   if err then
      wezterm.log_error(err)
   end

   ---@cast valid_opts Event.TabTitleOptions

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   -- Tab name will remain locked until the `reset-tab-title` is triggered
   wezterm.on('tabs.manual-update-tab-title', function(window, pane)
      window:perform_action(
         wezterm.action.PromptInputLine({
            -- title = 'InputLine: Manual Tab Title',
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
   wezterm.on('tabs.reset-tab-title', function(window, _pane)
      local tab = window:active_tab()
      local id = tab:tab_id()
      tab_list[id].title_locked = false
   end)

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   wezterm.on('tabs.toggle-tab-bar', function(window, _pane)
      local effective_config = window:effective_config()
      window:set_config_overrides({
         enable_tab_bar = not effective_config.enable_tab_bar,
         background = effective_config.background,
      })
   end)

   -- BUILTIN EVENT
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
      if not tab_list[tab.tab_id] then
         tab_list[tab.tab_id] = Tab:new()
      end

      tab_list[tab.tab_id]:update_cells(valid_opts, tab, hover, umath.clamp(max_width, 5, 22))
      return tab_list[tab.tab_id]:render()
   end)
end

return M
