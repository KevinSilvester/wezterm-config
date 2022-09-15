local get_os_name = require("utils.get_os_name")

local launch_menu = {}

if get_os_name.get_os_name() == "Windows" then
   launch_menu = {
      -- { label = "Ubuntu", args = { "wsl", "-d", "Ubuntu" }, domain = { DomainName = "ubuntu" } },
      {
         label = "PowerShell Core",
         args = { "pwsh" },
      },
      {
         label = "Command Prompt",
         args = { "cmd" },
      },
      {
         label = "Git Bash",
         args = { "C:\\Users\\kevin\\scoop\\apps\\git\\current\\bin\\bash.exe" },
      },
      {
         label = "Nushell",
         args = { "nu" },
      },
      {
         label = "PowerShell Desktop",
         args = { "powershell" },
      },
   }
else
   launch_menu = {
      { label = "bash", args = { "/usr/bin/bash" } },
      { label = "fish", args = { "/usr/bin/fish" } },
   }
end

return launch_menu
