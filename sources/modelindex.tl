local fmt = require("fmt")
require("oop")

local record ModelIndex
    m_row: integer
    m_column: integer

-- force decl:
    metamethod __call: function<Self>(Self, row?: integer, column?: integer): ModelIndex
end

function ModelIndex:new(row?: integer, column?: integer): ModelIndex
    local self = create(ModelIndex, "ModelIndex")

    self.m_row = row
    self.m_column = column

    if row and not column then
        self.m_column = 0
    end

    return self
end

setmetatable(ModelIndex, { __call = ModelIndex.new })

function ModelIndex:isValid(): boolean
    return self.m_row ~= nil and self.m_column ~= nil
end

function ModelIndex:__eq(target: ModelIndex): boolean
    return self.m_row == target.m_row and self.m_column == target.m_column
end

function ModelIndex:__tostring(): string
    if not self:isValid() then
        return fmt("%(invalid)", type(self))
    end

    if self.m_column == 0 then
        return fmt("%(row: %)", type(self), self.m_row)
    else
        return fmt("%(row: %, column: %)", type(self), self.m_row, self.m_column)
    end
end

function ModelIndex:row(): integer
    if self.m_row == nil then
        error(fmt("%: Cannot get a nil row", type(self)))
    end

    return self.m_row
end

function ModelIndex:column(): integer
    if self.m_row == nil then
        error(fmt("%: Cannot get a nil column", type(self)))
    end

    return self.m_column
end

return ModelIndex