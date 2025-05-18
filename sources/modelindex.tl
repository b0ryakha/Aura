require("oop")
require("format")

global record ModelIndex
    m_row: integer
    m_column: integer
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

function ModelIndex:isValid(): boolean
    return self.m_row ~= nil and self.m_column ~= nil
end

function ModelIndex:__eq(target: ModelIndex): boolean
    return self.m_row == target.m_row and self.m_column == target.m_column
end

function ModelIndex:__tostring(): string
    if not self:isValid() then
        return format("%(invalid)", type(self))
    end

    if self.m_column == 0 then
        return format("%(row: %)", type(self), self.m_row)
    else
        return format("%(row: %, column: %)", type(self), self.m_row, self.m_column)
    end
end

function ModelIndex:row(): integer
    if self.m_row == nil then
        error(format("%: Cannot get a nil row", type(self)))
    end

    return self.m_row
end

function ModelIndex:column(): integer
    if self.m_row == nil then
        error(format("%: Cannot get a nil column", type(self)))
    end

    return self.m_column
end