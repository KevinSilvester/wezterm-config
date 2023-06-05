local _math = math

_math.clamp = function(x, min, max)
   return x < min and min or (x > max and max or x)
end

_math.round = function(x, increment)
   if increment then
      return _math.round(x / increment) * increment
   end
   return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

return _math
