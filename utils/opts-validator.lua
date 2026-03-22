---@class Opt.boolean
---@field name string
---@field type 'boolean'
---@field default boolean
---@field required? boolean

---@class Opt.number
---@field name string
---@field type 'number'
---@field default number
---@field required? boolean
---@field enum? number[]

---@class Opt.string
---@field name string
---@field type 'string'
---@field default string
---@field required? boolean
---@field enum? string[]

---@class Opt.table
---@field name string
---@field type 'table'
---@field table_of 'string' | 'number' | 'boolean'
---@field default table
---@field required? boolean

---@alias OptsSchema (Opt.boolean | Opt.number | Opt.string | Opt.table)[]

---Check if a table contains a value
---@param tbl table
---@param value any
---@return boolean
local function tbl_contains(tbl, value)
   for _, v in ipairs(tbl) do
      if v == value then
         return true
      end
   end
   return false
end

---Validate the schema for the event options
---@param schema OptsSchema
local function validate_opts_schema(schema)
   local field_names = {}

   for _, opt in ipairs(schema) do
      assert(type(opt.name) == 'string', 'name must be a string')
      assert(not tbl_contains(field_names, opt.name), 'name must be unique')
      assert(
         type(opt.required) == 'boolean' or type(opt.required) == 'nil',
         'required must be a boolean'
      )
      assert(
         opt.type == 'boolean'
            or opt.type == 'number'
            or opt.type == 'string'
            or opt.type == 'table',
         'type must be one of boolean, number, string, table'
      )
      assert(type(opt.type) == 'string', 'type must be a string')
      assert(type(opt.default) == opt.type, 'default must be a ' .. opt.type)

      if opt.type == 'table' then
         assert(type(opt.table_of) == 'string', 'table_of must be a string')
         assert(
            opt.table_of == 'string' or opt.table_of == 'number' or opt.table_of == 'boolean',
            'table_of must be one of string, number, boolean'
         )
         for _, v in ipairs(opt.default) do
            assert(type(v) == opt.table_of, 'table values must be ' .. opt.table_of)
         end
      end

      if opt.enum then
         assert(type(opt.enum) == 'table', 'enum must be a table')
         for _, v in ipairs(opt.enum) do
            assert(type(v) == opt.type, 'enum values must be ' .. opt.type)
         end
      end
   end
end

---Event options validation class
---@class OptsValidator
---@field schema OptsSchema
local OptsValidator = {}
OptsValidator.__index = OptsValidator

---Create a new instance of OptsValidator
---@param schema OptsSchema
function OptsValidator:new(schema)
   validate_opts_schema(schema)
   local event_opts = { schema = schema }
   return setmetatable(event_opts, self)
end

---Validate the event options against the schema
---If the options are valid, it returns the options and nil
---If a field is invalid, it returns the default value and an error message
---@generic T
---@param opts T
---@return T
---@return string|nil
function OptsValidator:validate(opts)
   local errors = {}
   local valid_opts = {}

   for _, opt in ipairs(self.schema) do
      local value = opts[opt.name]
      local error = false

      if value == nil then
         if opt.required then
            table.insert(errors, string.format('Field "%s" is required', opt.name))
            error = true
         end
      end

      if value == nil then
         valid_opts[opt.name] = opt.default
         goto continue
      end

      if type(value) ~= opt.type then
         table.insert(errors, string.format('Field "%s" must of type "%s"', opt.name, opt.type))
         error = true
      end

      if
         (opt.type == 'string' or opt.type == 'number')
         and opt.enum ~= nil
         and not tbl_contains(opt.enum, value)
      then
         table.insert(
            errors,
            string.format('Field "%s" must be one of [%s]', opt.name, table.concat(opt.enum, ', '))
         )
         error = true
      end

      if opt.type == 'table' then
         for _, v in ipairs(value) do
            if type(v) ~= opt.table_of then
               table.insert(
                  errors,
                  string.format('Items in field "%s" must be of type "%s"', opt.name, opt.table_of)
               )
               error = true
               goto inner_continue
            end
         end
         ::inner_continue::
      end

      if error then
         valid_opts[opt.name] = opt.default
         goto continue
      end

      valid_opts[opt.name] = value
      ::continue::
   end

   if #errors > 0 then
      local err_msg = '\n~~EventOpts ERRORS~~\n'
      for _, err in ipairs(errors) do
         err_msg = err_msg .. '- ' .. err .. '\n'
      end
      return valid_opts, err_msg
   end

   return valid_opts, nil
end

return OptsValidator
