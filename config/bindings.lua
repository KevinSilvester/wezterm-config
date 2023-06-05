local wezterm = require('wezterm')
local act = wezterm.action

local keys = {
   -- misc/useful --
   { key = 'F1', mods = 'NONE', action = 'ActivateCopyMode' },
   { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },
   { key = 'F3', mods = 'NONE', action = act.ShowLauncher },
   { key = 'F4', mods = 'NONE', action = act.ShowTabNavigator },
   { key = 'F12', mods = 'NONE', action = act.ShowDebugOverlay },
   { key = 'f', mods = 'SUPER', action = act.Search({ CaseInSensitiveString = '' }) },

   -- copy/paste --
   { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
   { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't', mods = 'SUPER', action = act.SpawnTab('DefaultDomain') },
   { key = 't', mods = 'SUPER|CTRL', action = act.SpawnTab({ DomainName = 'WSL:Ubuntu' }) },
   { key = 'w', mods = 'SUPER', action = act.CloseCurrentTab({ confirm = false }) },

   -- tabs: navigation
   { key = '[', mods = 'SUPER', action = act.ActivateTabRelative(-1) },
   { key = ']', mods = 'SUPER', action = act.ActivateTabRelative(1) },
   { key = '[', mods = 'SUPER|CTRL', action = act.MoveTabRelative(-1) },
   { key = ']', mods = 'SUPER|CTRL', action = act.MoveTabRelative(1) },

   -- window --
   -- spawn windows
   { key = 'n', mods = 'SUPER', action = act.SpawnWindow },

   -- panes --
   -- panes: split panes
   {
      key = [[\]],
      mods = 'SUPER',
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   {
      key = [[\]],
      mods = 'SUPER|CTRL',
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },

   -- panes: zoom+close pane
   { key = 'z', mods = 'SUPER', action = act.TogglePaneZoomState },
   { key = 'w', mods = 'SUPER|CTRL', action = act.CloseCurrentPane({ confirm = false }) },

   -- panes: navigation
   { key = 'k', mods = 'SUPER', action = act.ActivatePaneDirection('Up') },
   { key = 'j', mods = 'SUPER', action = act.ActivatePaneDirection('Down') },
   { key = 'h', mods = 'SUPER', action = act.ActivatePaneDirection('Left') },
   { key = 'l', mods = 'SUPER', action = act.ActivatePaneDirection('Right') },

   -- panes: resize
   { key = 'k', mods = 'SUPER|CTRL', action = act.AdjustPaneSize({ 'Up', 1 }) },
   { key = 'j', mods = 'SUPER|CTRL', action = act.AdjustPaneSize({ 'Down', 1 }) },
   { key = 'h', mods = 'SUPER|CTRL', action = act.AdjustPaneSize({ 'Left', 1 }) },
   { key = 'l', mods = 'SUPER|CTRL', action = act.AdjustPaneSize({ 'Right', 1 }) },

   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
}

local key_tables = {
   resize_font = {
      { key = 'k', action = act.IncreaseFontSize },
      { key = 'j', action = act.DecreaseFontSize },
      { key = 'r', action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   leader = { key = 'Space', mods = 'CTRL|SHIFT' },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
