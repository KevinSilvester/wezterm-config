local get_os_name = require("utils.get_os_name")

local M = {}

if get_os_name.get_os_name() == "Windows" then
   M = {
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
   M = {
      { label = "bash", args = { "/usr/bin/bash" } },
      {
         label = "fish",
         args = { "/usr/bin/fish" },
      },
   }
end

return M
