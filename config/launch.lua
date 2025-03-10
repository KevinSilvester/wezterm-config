local platform = require('utils.platform')
local wezterm = require 'wezterm'

local options = {
   default_prog = {},
   launch_menu = {},
   default_cwd = nil
}

if platform.is_win then
   options.default_prog = { 'powershell' }
   options.launch_menu = {
      {
         label = 'PowerShell Desktop',
         args = { 'powershell' },
      },
      { label = 'Command Prompt', args = { 'cmd' } },
   }
   options.default_cwd = wezterm.home_dir .. '/Desktop/projects'
elseif platform.is_linux then
   options.default_prog = { 'bash', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
   }
end

return options
