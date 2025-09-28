local fmt = require("fmt")
require("oop")

---@class (exact) ModelIndex
---@operator call: ModelIndex
---@field private m_row integer | nil
---@field private m_column integer | nil
local ModelIndex = {}

---@param row? integer
---@param column? integer
---@return ModelIndex
function ModelIndex:new(row, column)
    local self = create(self, "ModelIndex")

    self.m_row = row
    self.m_column = column

    if row and not column then
        self.m_column = 0
    end

    return self
end

setmetatable(ModelIndex, { __call = ModelIndex.new })

---@return boolean
function ModelIndex:isValid()
    return self.m_row ~= nil and self.m_column ~= nil
end

---@param target ModelIndex
---@return boolean
function ModelIndex:__eq(target)
    return self.m_row == target.m_row and self.m_column == target.m_column
end

---@return string
function ModelIndex:__tostring()
    if not self:isValid() then
        return fmt("%(invalid)", type(self))
    end

    if self.m_column == 0 then
        return fmt("%(row: %)", type(self), self.m_row)
    else
        return fmt("%(row: %, column: %)", type(self), self.m_row, self.m_column)
    end
end

---@return integer
function ModelIndex:row()
    if self.m_row == nil then
        error(fmt("%: Cannot get a nil row", type(self)))
    end

    return self.m_row
end

---@return integer
function ModelIndex:column()
    if self.m_row == nil then
        error(fmt("%: Cannot get a nil column", type(self)))
    end

    return self.m_column
end

return ModelIndex