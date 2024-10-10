local wezterm = require('wezterm')
local launch_menu = require('config.launch').launch_menu
local domains = require('config.domains')

local nf = wezterm.nerdfonts

local M = {}

M.setup = function()
   wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
      if default_action and button == 'Left' then
         window:perform_action(default_action, pane)
      end

      if default_action and button == 'Right' then
         -- window:perform_action(
         --    wezterm.action.ShowLauncherArgs({
         --       title = nf.fa_rocket .. '  Select/Search:',
         --       flags = 'FUZZY|LAUNCH_MENU_ITEMS|DOMAINS',
         --    }),
         --    pane
         -- )
         -- window:perform_action(wezterm.action.SpawnTab({ DomainName = 'WSL:Ubuntu'}), pane)
         window:perform_action(wezterm.action.SpawnCommandInNewTab({ args = {'pwsh'}}), pane)
      end
      return false
   end)
end

return M
