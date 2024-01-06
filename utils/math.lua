local M = {}

M.clamp = function(x, min, max)
   return x < min and min or (x > max and max or x)
end

M.round = function(x, increment)
   if increment then
      return M.round(x / increment) * increment
   end
   return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

return M
