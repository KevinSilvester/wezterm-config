--
--[[ FormatItems: Begin ]]
---@class FormatItem.Text
---@field Text string

---@class FormatItem.Attribute.Intensity
---@field Intensity 'Bold'|'Half'|'Normal'

---@class FormatItem.Attribute.Italic
---@field Italic boolean

---@class FormatItem.Attribute.Underline
---@field Underline 'None'|'Single'|'Double'|'Curly'

---@class FormatItem.Attribute
---@field Attribute FormatItem.Attribute.Intensity|FormatItem.Attribute.Italic|FormatItem.Attribute.Underline

---@class FormatItem.Foreground
---@field Background {Color: string}

---@class FormatItem.Background
---@field Foreground {Color: string}

---@alias FormatItem.Reset 'ResetAttributes'

---@alias FormatItem FormatItem.Text|FormatItem.Attribute|FormatItem.Foreground|FormatItem.Background|FormatItem.Reset
--[[ FormatItems: End ]]

local attr = {}
local attr_mt = {}

---@param type 'Bold'|'Half'|'Normal'
---@return {Attribute: FormatItem.Attribute.Intensity}
attr.intensity = function(type)
   return { Attribute = { Intensity = type } }
end

---@return {Attribute: FormatItem.Attribute.Italic}
attr.italic = function()
   return { Attribute = { Italic = true } }
end

---@param type 'None'|'Single'|'Double'|'Curly'
---@return {Attribute: FormatItem.Attribute.Underline}
attr.underline = function(type)
   return { Attribute = { Underline = type } }
end

---@vararg FormatItem.Attribute
---@return FormatItem.Attribute[]
attr_mt.__call = function(_, ...)
   return { ... }
end

---@class Cells.Colors
---@field default {bg: string, fg: string}
---@field [string] {bg: string, fg: string}

---@class Cells.Segment
---@field color string
---@field items FormatItem[]

---Format item generator for `wezterm.format` (ref: <https://wezfurlong.org/wezterm/config/lua/wezterm/format.html>)
---@class Cells
---@field segments table<string|number, Cells.Segment>
---@field colors Cells.Colors
local Cells = {}
Cells.__index = Cells

Cells.attr = setmetatable(attr, attr_mt)

---@param colors Cells.Colors
function Cells:new(colors)
   return setmetatable({
      segments = {},
      colors = colors,
   }, self)
end

---@param segment_id string|number the segment id
---@param text string the text to push
---@param color string|'default' the color variant to use (default is 'default')
---@param attributes FormatItem.Attribute[]|nil use bold text
function Cells:push(segment_id, text, color, attributes)
   color = color or 'default'
   local colors = self.colors[color]
   if not colors then
      error('Color variant "' .. color .. '" not found')
   end

   ---@type FormatItem[]
   local items = {}

   table.insert(items, { Background = { Color = colors.bg } })
   table.insert(items, { Foreground = { Color = colors.fg } })
   if attributes and #attributes > 0 then
      for _, attr_ in ipairs(attributes) do
         table.insert(items, attr_)
      end
   end
   table.insert(items, { Text = text })
   table.insert(items, 'ResetAttributes')

   ---@type Cells.Segment
   self.segments[segment_id] = {
      color = color,
      items = items,
   }

   return self
end

---@private
---@param segment_id string|number the segment id
function Cells:_check_segment(segment_id)
   if not self.segments[segment_id] then
      error('Segment "' .. segment_id .. '" not found')
   end
end

---@private
---@param color string
function Cells:_check_color(color)
   if not self.colors[color] then
      error('Color variant "' .. color .. '" not found')
   end
end

---@param segment_id string|number the segment id
---@param text string the text to push
function Cells:update_segment_text(segment_id, text)
   self:_check_segment(segment_id)
   local idx = #self.segments[segment_id].items - 1
   self.segments[segment_id].items[idx] = { Text = text }
   return self
end

---@param segment_id string|number the segment id
---@param color string|'default' the color variant to use (default is 'default')
function Cells:update_segment_colors(segment_id, color)
   color = color or 'default'
   self:_check_segment(segment_id)
   self:_check_color(color)

   self.segments[segment_id].items[1] = { Background = { Color = self.colors[color].bg } }
   self.segments[segment_id].items[2] = { Foreground = { Color = self.colors[color].fg } }
   return self
end

---@param ids table<string|number> the segment ids
---@return FormatItem[]
function Cells:render(ids)
   local cells = {}

   for _, id in ipairs(ids) do
      self:_check_segment(id)

      for _, item in pairs(self.segments[id].items) do
         table.insert(cells, item)
      end
   end
   return cells
end

---@return FormatItem[]
function Cells:render_all()
   local cells = {}
   for _, segment in pairs(self.segments) do
      for _, item in pairs(segment.items) do
         table.insert(cells, item)
      end
   end
   return cells
end

function Cells:reset()
   self.segments = {}
end

return Cells
