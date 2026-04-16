local M = {}

---@param str string
---@param prefix string
---@return boolean
M.starts_with = function(str, prefix)
   return str:sub(1, #prefix) == prefix
end

---@param str string
---@param suffix string
---@return boolean
M.ends_with = function(str, suffix)
   return str:sub(-#suffix) == suffix
end

return M
