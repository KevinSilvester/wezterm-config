------------------------------------------------------------------------------------------
-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614 --
------------------------------------------------------------------------------------------

local wezterm = require('wezterm')
local Cells = require('utils.cells')
local OptsValidator = require('utils.opts-validator')
local ustr = require('utils.str')

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

---Commit date part of release tag `20250209-182623-44866cc1`
local PROGRESS_MIN_VERSION = 20250209
local PROGRESS_STALE_AFTER = 30 -- seconds

local ICON_SCIRCLE_LEFT = nf.ple_left_half_circle_thick --[[  ]]
local ICON_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[  ]]

-- stylua: ignore
---@enum PrefixIcon
local ICON_PREFIX = {
   admin    = nf.md_shield_half_full, --[[ 󰞀 ]]
   wsl      = nf.cod_terminal_linux,  --[[  ]]
   debug    = nf.fa_bug,              --[[  ]]
   select   = nf.md_selection_search, --[[ 󱈅 ]]
   --  search = '🔭',
   launcher = nf.oct_rocket,          --[[  ]]
   edit     = nf.fa_edit,             --[[  ]]
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

local ICON_PROGRESS_IND_FRAMES = {
   [1] = '◜',
   [2] = '◠',
   [3] = '◝',
   [4] = '◞',
   [5] = '◡',
   [6] = '◟',
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

   -- if Debug-Overlay is active
   if base_title == 'Debug' then
      prefix_icon = ICON_PREFIX.debug
      base_title = base_title:upper()

   -- if built-in Launcher is active
   elseif base_title == 'Launcher' then
      prefix_icon = ICON_PREFIX.launcher
      base_title = base_title:upper()

   -- if shell is elevated to windows administrator
   elseif
      ustr.starts_with(base_title, 'Administrator:') or ustr.ends_with(base_title, '(Admin)')
   then
      prefix_icon = ICON_PREFIX.admin
      base_title = base_title:gsub('Administrator: ', ''):gsub('%(Admin%)', '')

   -- if shell is wsl instance
   elseif ustr.starts_with(process_name, 'wsl') then
      prefix_icon = ICON_PREFIX.wsl

   -- if `PromptInputLine` or `InputSelector` overlay is active
   elseif ustr.starts_with(base_title, 'InputSelector:') then
      prefix_icon = ICON_PREFIX.select
      base_title = base_title:gsub('InputSelector: ', '')
   elseif ustr.starts_with(base_title, 'InputLine:') then
      prefix_icon = ICON_PREFIX.edit
      base_title = base_title:gsub('InputLine: ', '')
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

   if wezterm.column_width(title) > max_width - inset then
      local diff = wezterm.column_width(title) - max_width + inset
      title = wezterm.truncate_right(title, wezterm.column_width(title) - diff)
   else
      local padding = max_width - wezterm.column_width(title) - inset
      title = title .. string.rep(' ', padding)
   end

   return title
end

local progress_stale = (function()
   -- stylua: ignore
   local status_score = {
      indeterminate = 100,
      error         = 200,
      percentage    = 300,
   }

   ---@type {sum: integer, last_changed: integer}[]
   local entries = {}

   ---Mark progress value as stale if the output hasn't changed in 30 seconds
   ---@param tab_id integer
   ---@param pane_id integer
   ---@param status 'indeterminate'|'error'|'percentage'
   ---@param pct integer
   ---@return boolean `true` if stale
   return function(tab_id, pane_id, status, pct)
      local entry_id = (tab_id << 4) | pane_id

      if not entries[entry_id] then
         entries[entry_id] = {}
         entries[entry_id].sum = status_score[status] + pct
         entries[entry_id].last_changed = os.time()
         return false
      end

      local sum = status_score[status] + pct

      if sum ~= entries[entry_id].sum then
         entries[entry_id].sum = sum
         entries[entry_id].last_changed = os.time()
         return false
      end

      return os.time() - entries[entry_id].last_changed > PROGRESS_STALE_AFTER
   end
end)()

---@param options Event.TabTitleOptions
---@param tab_id integer
---@param panes PaneInformation[]
---@return {icon: string?, status: 'indeterminate'|'percentage'|'error'?}[]
local function check_progress(options, tab_id, panes)
   if not options.show_progress then
      return {}
   end

   local progress = {}
   local limit = 3

   for i, pane in ipairs(panes) do
      if i > limit then
         break
      end

      local prog = pane.progress
      local status = nil
      local icon = nil
      local pct = 0

      if prog == 'Indeterminate' then
         status = 'indeterminate'
         icon = _ind_to_frame()
      elseif prog.Percentage ~= nil then
         status = 'percentage'
         icon, pct = _pct_to_frame(prog.Percentage), prog.Percentage
      elseif prog.Error ~= nil then
         status = 'error'
         icon, pct = _pct_to_frame(prog.Error), prog.Error
      end

      if icon and status then
         if not progress_stale(tab_id, pane.pane_id, status, pct) then
            table.insert(progress, { icon = icon, status = status })
         end
      end
   end

   return progress
end

---@param options Event.TabTitleOptions
---@param is_active boolean
---@param panes PaneInformation[]
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

local progress_cells = Cells:new():add_segment(RS.progress):add_segment(RS.padding, ' ')
local title_cells = Cells:new()
   :add_segment(RS.scircle_left, ICON_SCIRCLE_LEFT)
   :add_segment(RS.icon)
   :add_segment(RS.title, nil, nil, attr(attr.intensity('Bold')))
   :add_nested_segment(RS.progress)
   :add_segment(RS.unseen_output)
   :add_segment(RS.padding, ' ')
   :add_segment(RS.scircle_right, ICON_SCIRCLE_RIGHT)

---@class Tab
---@field title_locked boolean
---@field locked_title string
---@field has_icon boolean
---@field has_unseen boolean
---@field has_progress boolean
local Tab = {}
Tab.__index = Tab

---@return Tab
function Tab:new()
   local tab = {
      title_locked = false,
      locked_title = '',
      has_icon = false,
      has_unseen = false,
      has_progress = false,
   }

   return setmetatable(tab, self)
end

---@param event_opts Event.TabTitleOptions
---@param tab TabInformation
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
   local progress = check_progress(event_opts, tab.tab_id, tab.panes)
   local inset = TITLE_INSET.default

   -- Prefix icons
   if prefix_icon then
      inset = inset + TITLE_INSET.increment
      self.has_icon = true
      title_cells:update_segment_text(RS.icon, prefix_icon)
   end

   -- Unseen output icon
   if unseen_icon then
      inset = inset + TITLE_INSET.increment
      self.has_unseen = true
      title_cells:update_segment_text(RS.unseen_output, unseen_icon)
   end

   -- Progress icons - BEGIN
   inset = inset + (TITLE_INSET.increment * #progress)
   self.has_progress = #progress > 0

   ---@type FormatItem[][]
   local nested_items = {}

   if self.has_progress then
      for i, prog in ipairs(progress) do
         local prog_colors = 'progress_' .. prog.status .. '_' .. tab_state
         progress_cells
            :update_segment_text(RS.progress, prog.icon)
            :update_segment_colors(RS.progress, colors[prog_colors])
            :update_segment_colors(RS.padding, colors['text_' .. tab_state])
         if i == #progress then
            table.insert(nested_items, progress_cells:render({ RS.progress }))
         else
            table.insert(nested_items, progress_cells:render({ RS.progress, RS.padding }))
         end
      end
   end

   title_cells:update_nested_segment(RS.progress, nested_items)
   -- Progress icons - END

   if self.title_locked then
      process_name = ''
      base_title = self.locked_title
   end

   local title = create_title(process_name, base_title, max_width, inset)

   title_cells:update_segment_text(RS.title, title)

   -- stylua: ignore
   title_cells
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

---@return FormatItem[]
function Tab:render()
   local variant_idx = self.has_icon and 5 or 1
   if self.has_unseen then
      variant_idx = variant_idx + 1
   end
   if self.has_progress then
      variant_idx = variant_idx + 2
   end
   return title_cells:render(RV[variant_idx])
end

---@type Tab[]
local tab_list = {}

---NOTE:
---Progress indicator is only available for WezTerm nightly versions `20250209-182623-44866cc1` and onwards.
---If an older version is used, the `show_progress` options will be hard-set to `false`.
---@param opts? Event.TabTitleOptionsInput Default: {unseen_icon = 'circle', hide_active_tab_unseen = true, show_progress = true}
M.setup = function(opts)
   local valid_opts, err = EVENT_OPTS:validate(opts or {})

   if err then
      wezterm.log_error(err)
   end

   ---@cast valid_opts Event.TabTitleOptions

   if tonumber(wezterm.version:sub(1, 8)) < PROGRESS_MIN_VERSION then
      valid_opts.show_progress = false
   end

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   -- Tab name will remain locked until the `reset-tab-title` is triggered
   wezterm.on('tabs.manual-update-tab-title', function(window, pane)
      local title = nil

      if ustr.ends_with(wezterm.version, 'custom-build') then
         title = 'InputLine: Manual Tab Title'
      end

      window:perform_action(
         wezterm.action.PromptInputLine({
            title = title,
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
      ---@cast window Window
      local tab = window:active_tab()
      local id = tab:tab_id()
      tab_list[id].title_locked = false
   end)

   -- CUSTOM EVENT
   -- Event listener to manually update the tab name
   wezterm.on('tabs.toggle-tab-bar', function(window, _pane)
      ---@cast window Window
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

      -- `max_width` refers to the `tab_max_width` option set in `config/appearance.lua`
      tab_list[tab.tab_id]:update_cells(valid_opts, tab, hover, max_width)
      return tab_list[tab.tab_id]:render()
   end)
end

return M
