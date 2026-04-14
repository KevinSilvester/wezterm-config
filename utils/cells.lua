---@diagnostic disable: duplicate-doc-alias
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

---@alias Cells.SegmentColors {bg?: string|'UNSET', fg?: string|'UNSET'}

---@class FormatCells.Segment
---@field items FormatItem[]
---@field has_bg boolean
---@field has_fg boolean
---@field nested false

---@class FormatCells.NestedSegment
---@field nested_items FormatItem[][]
---@field nested true

---Format item generator for `wezterm.format` (ref: <https://wezfurlong.org/wezterm/config/lua/wezterm/format.html>)
---@class FormatCells
---@field segments table<string|number, FormatCells.Segment|FormatCells.NestedSegment>
local Cells = {}
Cells.__index = Cells

---Attribute generator for `wezterm.format` (ref: <https://wezfurlong.org/wezterm/config/lua/wezterm/format.html>)
---@class Cells.Attributes
---@field intensity fun(type: 'Bold'|'Half'|'Normal'): {Attribute: FormatItem.Attribute.Intensity}
---@field underline fun(type: 'None'|'Single'|'Double'|'Curly'): {Attribute: FormatItem.Attribute.Underline}
---@field italic fun(): {Attribute: FormatItem.Attribute.Italic}
---@overload fun(...: FormatItem.Attribute): FormatItem.Attribute[]
Cells.attr = setmetatable(attr, {
   __call = function(_, ...)
      return { ... }
   end,
})

---@return FormatCells
function Cells:new()
   return setmetatable({
      segments = {},
   }, self)
end

---Add a new segment with unique `segment_id` to the cells
---@param segment_id string|number the segment id
---@param text? string the text to push
---@param color? Cells.SegmentColors the bg and fg colors for text
---@param attributes? FormatItem.Attribute[] use bold text
function Cells:add_segment(segment_id, text, color, attributes)
   color = color or {}

   ---@type FormatItem[]
   local items = {}

   if color.bg then
      assert(color.bg ~= 'UNSET', 'Cannot use UNSET when adding new segment')
      table.insert(items, { Background = { Color = color.bg } })
   end
   if color.fg then
      assert(color.bg ~= 'UNSET', 'Cannot use UNSET when adding new segment')
      table.insert(items, { Foreground = { Color = color.fg } })
   end
   if attributes and #attributes > 0 then
      for _, attr_ in ipairs(attributes) do
         table.insert(items, attr_)
      end
   end
   table.insert(items, { Text = text or '' })
   table.insert(items, 'ResetAttributes')

   ---@type FormatCells.Segment
   self.segments[segment_id] = {
      items = items,
      has_bg = color.bg ~= nil,
      has_fg = color.fg ~= nil,
      nested = false,
   }

   return self
end

---Add a nested segment with a unique `segment_id` to cells
---@param segment_id string|number the segment id
---@param items? FormatItem[][] the items to push
---@return FormatCells
function Cells:add_nested_segment(segment_id, items)
   ---@type FormatCells.NestedSegment
   self.segments[segment_id] = {
      nested_items = items or {},
      nested = true,
   }
   return self
end

---Check if the segment exists
---@private
---@param segment_id string|number the segment id
function Cells:_check_segment(segment_id)
   assert(self.segments[segment_id], 'Segment "' .. segment_id .. '" not found')
end

---Check if the segment is nested
---@param segment_id string|number the segment id
---@param nested boolean whether the segment is nested or not
function Cells:_check_nested(segment_id, nested)
   assert(
      self.segments[segment_id].nested == nested,
      'Segment "' .. segment_id .. '" is ' .. (nested and 'not ' or '') .. 'a nested segment'
   )
end

---check if the segment is not nested

---Update the text of a segment
---@param segment_id string|number the segment id
---@param text string the text to push
function Cells:update_segment_text(segment_id, text)
   self:_check_segment(segment_id)
   self:_check_nested(segment_id, false)
   local idx = #self.segments[segment_id].items - 1
   self.segments[segment_id].items[idx] = { Text = text }
   return self
end

---Update the colors of a segment
---@param segment_id string|number the segment id
---@param color Cells.SegmentColors the bg and fg colors for text
function Cells:update_segment_colors(segment_id, color)
   assert(type(color) == 'table', 'Color must be a table')

   self:_check_segment(segment_id)
   self:_check_nested(segment_id, false)

   local has_bg = self.segments[segment_id].has_bg
   local has_fg = self.segments[segment_id].has_fg

   if color.bg then
      if has_bg and color.bg == 'UNSET' then
         table.remove(self.segments[segment_id].items, 1)
         has_bg = false
         goto bg_end
      end

      if has_bg then
         self.segments[segment_id].items[1] = { Background = { Color = color.bg } }
      else
         table.insert(self.segments[segment_id].items, 1, { Background = { Color = color.bg } })
         has_bg = true
      end
   end
   ::bg_end::

   if color.fg then
      local fg_idx = has_bg and 2 or 1
      if has_fg and color.fg == 'UNSET' then
         table.remove(self.segments[segment_id].items, fg_idx)
         has_fg = false
         goto fg_end
      end

      if has_fg then
         self.segments[segment_id].items[fg_idx] = { Foreground = { Color = color.fg } }
      else
         table.insert(
            self.segments[segment_id].items,
            fg_idx,
            { Foreground = { Color = color.fg } }
         )
         has_fg = true
      end
   end
   ::fg_end::

   self.segments[segment_id].has_bg = has_bg
   self.segments[segment_id].has_fg = has_fg
   return self
end

---Update the items of a nested segment
---@param segment_id string|number the segment id
---@param items FormatItem[][] the items to push
---@return FormatCells
function Cells:update_nested_segment(segment_id, items)
   self:_check_segment(segment_id)
   self:_check_nested(segment_id, true)
   self.segments[segment_id].nested_items = items
   return self
end

---Extend the items of a nested segment
---@param segment_id string|number the segment id
---@param items FormatItem[] the items to push
---@return FormatCells
function Cells:extend_nested_segment(segment_id, items)
   self:_check_segment(segment_id)
   self:_check_nested(segment_id, true)
   for _, item in pairs(items) do
      table.insert(self.segments[segment_id].nested_items, item)
   end
   return self
end

---Convert specific segments into a format that `wezterm.format` can use
---Segments will rendered in the order of the `ids` table
---@param ids table<string|number> the segment ids
---@return FormatItem[]
function Cells:render(ids)
   local cells = {}

   for _, id in ipairs(ids) do
      self:_check_segment(id)

      if self.segments[id].nested then
         for _, nested in pairs(self.segments[id].nested_items) do
            for _, item in pairs(nested) do
               table.insert(cells, item)
            end
         end
         goto continue
      end

      for _, item in pairs(self.segments[id].items) do
         table.insert(cells, item)
      end
      ::continue::
   end
   return cells
end

---Convert all segments into a format that `wezterm.format` can use
--- WARNING: Segments may not be in the same order as they were added if the `segment_id` is a string
---
---@return FormatItem[]
function Cells:render_all()
   local cells = {}
   for _, segment in pairs(self.segments) do
      if segment.nested then
         for _, nested in pairs(segment.nested_items) do
            for _, item in pairs(nested) do
               table.insert(cells, item)
            end
         end
         goto continue
      end

      for _, item in pairs(segment.items) do
         table.insert(cells, item)
      end

      ::continue::
   end
   return cells
end

---Reset all segments
function Cells:reset()
   self.segments = {}
end

return Cells
