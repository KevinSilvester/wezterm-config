local wezterm = require('wezterm')
local platform = require('utils.platform')
local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT'
   mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua: ignore
---@type Key[]
local keys = {
   -- keyboard reference
   {
      key = 'F6',
      mods = 'NONE',
      action = act.InputSelector({
         title = 'WezTerm Keyboard Shortcuts | Type to filter | Esc to close',
         choices = require('config.cheatsheet').choices,
         fuzzy = true,
         fuzzy_description = 'Find a shortcut: ',
         action = wezterm.action_callback(function() end),
      }),
   },

   -- pane creation: Alt + Q/E/R/T
   { key = 'q', mods = 'ALT', action = act.SplitPane({ direction = 'Left' }) },
   { key = 'e', mods = 'ALT', action = act.SplitPane({ direction = 'Right' }) },
   { key = 'r', mods = 'ALT', action = act.SplitPane({ direction = 'Down' }) },
   { key = 't', mods = 'ALT', action = act.SplitPane({ direction = 'Up' }) },

   -- pane focus: Shift + arrow keys
   { key = 'LeftArrow',  mods = 'SHIFT', action = act.ActivatePaneDirection('Left') },
   { key = 'RightArrow', mods = 'SHIFT', action = act.ActivatePaneDirection('Right') },
   { key = 'UpArrow',    mods = 'SHIFT', action = act.ActivatePaneDirection('Up') },
   { key = 'DownArrow',  mods = 'SHIFT', action = act.ActivatePaneDirection('Down') },

   -- pane resizing: Alt + Shift + arrow keys
   { key = 'LeftArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Left', 1 }) },
   { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Right', 1 }) },
   { key = 'UpArrow',    mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Up', 1 }) },
   { key = 'DownArrow',  mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Down', 1 }) },

   -- Vim-like terminal scrollback copy mode
   { key = 'g', mods = 'ALT', action = act.ActivateCopyMode },

   -- panes: close and zoom
   { key = 'w', mods = 'ALT', action = act.CloseCurrentPane({ confirm = false }) },
   { key = 'Enter', mods = 'ALT', action = act.TogglePaneZoomState },

   -- tabs and windows
   { key = '0', mods = 'ALT', action = act.SpawnTab('DefaultDomain') },
   { key = 't', mods = 'CTRL|ALT', action = act.SpawnTab({ DomainName = 'Ubuntu' }) },
   { key = 'w', mods = 'CTRL|ALT', action = act.CloseCurrentTab({ confirm = false }) },
   { key = '1', mods = 'ALT', action = act.ActivateTab(0) },
   { key = '2', mods = 'ALT', action = act.ActivateTab(1) },
   { key = '3', mods = 'ALT', action = act.ActivateTab(2) },
   { key = '4', mods = 'ALT', action = act.ActivateTab(3) },
   { key = '5', mods = 'ALT', action = act.ActivateTab(4) },
   { key = '6', mods = 'ALT', action = act.ActivateTab(5) },
   { key = '7', mods = 'ALT', action = act.ActivateTab(6) },
   { key = '8', mods = 'ALT', action = act.ActivateTab(7) },
   { key = '9', mods = 'ALT', action = act.ActivateTab(8) },
   { key = '[', mods = 'ALT', action = act.ActivateTabRelative(-1) },
   { key = ']', mods = 'ALT', action = act.ActivateTabRelative(1) },
   { key = 'n', mods = 'ALT', action = act.SpawnWindow },

   -- quick access and navigation
   { key = 'p', mods = 'CTRL|ALT', action = act.PaneSelect },
   { key = '\\', mods = 'ALT', action = act.ActivateLastTab },
   { key = '[', mods = 'ALT|SHIFT', action = act.MoveTabRelative(-1) },
   { key = ']', mods = 'ALT|SHIFT', action = act.MoveTabRelative(1) },

   -- font controls
   { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
   { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
   { key = '0', mods = 'CTRL', action = act.ResetFontSize },

   -- general utilities
   { key = 'r', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
   { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback('ScrollbackOnly') },
   { key = 'f', mods = 'CTRL|SHIFT', action = act.Search({ CaseInSensitiveString = '' }) },
   { key = ' ', mods = 'CTRL|SHIFT', action = act.QuickSelect },
   { key = 'F1', mods = 'NONE', action = act.ActivateCopyMode },
   { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
   { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
   { key = 'F4', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   { key = 'F5', mods = 'NONE', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },
   { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
   { key = 'F12', mods = 'NONE', action = act.ShowDebugOverlay },
   { key = 'f', mods = 'ALT', action = act.Search({ CaseInSensitiveString = '' }) },
   {
      key = 'u',
      mods = 'CTRL|ALT',
      action = wezterm.action.QuickSelectArgs({
         label = 'open url',
         patterns = {
            '\\((https?://\\S+)\\)',
            '\\[(https?://\\S+)\\]',
            '\\{(https?://\\S+)\\}',
            '<(https?://\\S+)>',
            '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- clipboard
   { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
   { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },
   { key = 'n', mods = 'CTRL|SHIFT', action = act.SendString('\\u{2660}') },
   { key = 's', mods = 'CTRL|SHIFT', action = act.SendString('\\u{203D}') },

   -- shell cursor movement
   { key = 'LeftArrow', mods = 'ALT', action = act.SendString('\\u{1b}OH') },
   { key = 'RightArrow', mods = 'ALT', action = act.SendString('\\u{1b}OF') },
   { key = 'Backspace', mods = 'ALT', action = act.SendString('\\u{15}') },

   -- background controls
   {
      key = '/',
      mods = 'ALT',
      action = wezterm.action_callback(function(window) backdrops:random(window) end),
   },
   {
      key = ',',
      mods = 'ALT',
      action = wezterm.action_callback(function(window) backdrops:cycle_back(window) end),
   },
   {
      key = '.',
      mods = 'ALT',
      action = wezterm.action_callback(function(window) backdrops:cycle_forward(window) end),
   },
   {
      key = '/',
      mods = 'CTRL|ALT',
      action = act.InputSelector({
         title = 'Select Background',
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = 'Select Background: ',
         action = wezterm.action_callback(function(window, _pane, idx)
            if idx then backdrops:set_img(window, tonumber(idx)) end
         end),
      }),
   },
   {
      key = 'b',
      mods = 'ALT',
      action = wezterm.action_callback(function(window) backdrops:toggle_focus(window) end),
   },

   -- scrollback
   { key = 'u', mods = 'ALT', action = act.ScrollByLine(-5) },
   { key = 'd', mods = 'ALT', action = act.ScrollByLine(5) },
   { key = 'PageUp', mods = 'NONE', action = act.ScrollByPage(-0.75) },
   { key = 'PageDown', mods = 'NONE', action = act.ScrollByPage(0.75) },

   -- window sizing (kept from original config; disabled on Windows for safety)
   {
      key = '-',
      mods = 'ALT',
      action = wezterm.action_callback(function(window)
         local dimensions = window:get_dimensions()
         if platform.is_win or dimensions.is_full_screen then return end
         window:set_inner_size(dimensions.pixel_width - 50, dimensions.pixel_height - 50)
      end),
   },
   {
      key = '=',
      mods = 'ALT',
      action = wezterm.action_callback(function(window)
         local dimensions = window:get_dimensions()
         if platform.is_win or dimensions.is_full_screen then return end
         window:set_inner_size(dimensions.pixel_width + 50, dimensions.pixel_height + 50)
      end),
   },
   {
      key = 'Enter',
      mods = 'CTRL|ALT',
      action = wezterm.action_callback(function(window) window:maximize() end),
   },
}

local key_tables = {}
local mouse_bindings = {
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   leader = { key = 'Space', mods = 'CTRL|ALT' },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
