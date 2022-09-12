local get_os_name = require("utils.get_os_name")

if get_os_name.get_os_name() == "Windows" then
   return { "pwsh.exe" }
else
   return { "fish" }
end
