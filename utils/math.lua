local M = {}

---Clamps a number between a minimum and maximum value.
---@param x number The number to clamp.
---@param min number The minimum value.
---@param max number The maximum value.
M.clamp = function(x, min, max)
   return x < min and min or (x > max and max or x)
end

---Rounds a number to the nearest integer or to the nearest increment if provided.
---@param x number The number to round.
---@param increment number? The increment to round to (optional).
M.round = function(x, increment)
   if increment then
      return M.round(x / increment) * increment
   end
   return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

return M
