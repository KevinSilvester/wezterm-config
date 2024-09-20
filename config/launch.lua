local platform = require('utils.platform')()

local options = {
   default_prog = {},
   launch_menu = {},
}

if platform.is_win then
   options.default_prog = { 'pwsh', '-NoLogo' }
   options.launch_menu = {
      { label = 'PowerShell Core', args = { 'pwsh', '-NoLogo' } },
      { label = 'PowerShell Desktop', args = { 'powershell' } },
      { label = 'Command Prompt', args = { 'cmd' } },
      { label = 'Windows Subsystem for Linux', args = { 'wsl' } },
      { label = 'Nushell', args = { 'nu' } },
      {
         label = 'Git Bash',
         args = { 'C:\\Users\\Shadow\\scoop\\apps\\git\\current\\bin\\bash.exe' },
      },
   }
elseif platform.is_mac then
   options.default_prog = { '/usr/local/bin/zsh', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { '/usr/local/bin/bash', '-l' } },
      { label = 'Fish', args = { '/usr/local/bin/fish', '-l' } },
      { label = 'Nushell', args = { '/usr/local/bin/nu', '-l' } },
      { label = 'Zsh', args = { '/usr/local/bin/zsh', '-l' } },
      { label = 'NuShell', args = { '/usr/local/bin/nu', '-l' } },
      { label = 'Murex', args = { '/usr/local/bin/murex' } },
      { label = 'Ysh', args = { '/usr/local/bin/ysh', '-l' } },
      { label = 'Osh', args = { '/usr/local/bin/osh', '-l' } },
      { label = 'PowerShell', args = { '/usr/local/bin/pwsh-preview', '-l' } },
      { label = 'Xonsh', args = { '/usr/local/bin/xonsh', '-l' } },
   }
elseif platform.is_linux then
   options.default_prog = { 'zsh', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { 'fish', '-l' } },
      { label = 'Zsh', args = { 'zsh', '-l' } },
      { label = 'NuShell', args = { '/home/linuxbrew/.linuxbrew/bin/nu', '-l' } },
      { label = 'Murex', args = { '/home/linuxbrew/.linuxbrew/bin/murex' } },
      { label = 'Ysh', args = { '/home/linuxbrew/.linuxbrew/bin/ysh', '-l' } },
      { label = 'Osh', args = { '/home/linuxbrew/.linuxbrew/bin/osh', '-l' } },
      { label = 'Elvish', args = { 'elvish' } },
      { label = 'Xonsh', args = { 'xonsh', '-l' } },
   }
end

return options
