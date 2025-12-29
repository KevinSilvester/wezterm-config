local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

M.setup = function()
   -- Handle clicks on the close button
   wezterm.on('tab-bar-click', function(window, pane, tab, bar, event_id, click_count)
      if event_id == 'close_tab' then         window:perform_action(act.CloseTab, pane)
         return true
      end
   end)
end

return M