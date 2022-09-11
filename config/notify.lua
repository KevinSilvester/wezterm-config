local wezterm = require("wezterm")
local M = {}

M.setup = function()
   wezterm.on("window-config-reloaded", function(window, pane)
      window:toast_notification("wezterm", "configuration reloaded!", nil, 4000)
   end)
end

return M
