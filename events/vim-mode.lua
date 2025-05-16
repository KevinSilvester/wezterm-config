local wezterm = require('wezterm')

local M = {}

M.setup = function()
   wezterm.on('update-status', function(window, pane)
      local mode = pane:get_foreground_process_name()
      if mode:find('vim') then
         -- Check if we're in normal mode by looking for the "-- NORMAL --" text
         local success, stdout, stderr = wezterm.run_child_process({'sh', '-c', 'ps -p ' .. pane:get_foreground_process_id() .. ' -o command='})
         if success and stdout:find('-- NORMAL --') then
            window:set_config_overrides({
               cursor_style = 'Block'
            })
         else
            window:set_config_overrides({
               cursor_style = 'BlinkingBlock'
            })
         end
      else
         window:set_config_overrides({
            cursor_style = 'BlinkingBlock'
         })
      end
   end)
end

return M 