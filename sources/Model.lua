local ModelIndex = require("ModelIndex")
local Signal = require("Signal")
local fmt = require("fmt")
require("oop")

---@class (exact) Model
---@operator call: Model
---@field private items table<ModelIndex, ModelItem>
---@field private count Vector2
---
---@field dataChanged Signal
local Model = {}

---@return Model
function Model:new()
    local self = create(Model, "Model")

    self.items = {}
    self.count = Vector2:new(0, 0)

    self.dataChanged = Signal()

    return self
end

setmetatable(Model, { __call = Model.new })

---@private
---@param index ModelIndex
---@return ModelIndex
function Model:resolveIndex(index)
    for resolved, _ in pairs(self.items) do
        if index == resolved then
            return resolved
        end
    end

    return ModelIndex()
end

---@virtual
---@param index ModelIndex
---@param role? ModelItem.Role
---@return ModelItem.Value
function Model:data(index, role)
    local resolved = self:resolveIndex(index)
    if not resolved:isValid() then
        error(fmt("%: Cannot find a value at an index: %", type(self), index))
    end

    return self.items[resolved]:get(role or "Display")
end

---@virtual
---@return integer
function Model:rowCount()
    return self.count.y
end

---@virtual
---@return integer
function Model:columnCount()
    return self.count.x
end

---@virtual
---@param index ModelIndex
---@param item ModelItem
---@return boolean
function Model:insert(index, item)
    if not index:isValid() or self:resolveIndex(index):isValid() then
        return false
    end

    self.items[index] = item
    self.count.x = math.max(self.count.x, index:column())
    self.count.y = math.max(self.count.x, index:row())

    emit(self.dataChanged)

    return true
end

---@virtual
---@param index ModelIndex
---@return boolean
function Model:remove(index)
    local resolved = self:resolveIndex(index)

    if not index:isValid() or not resolved:isValid() then
        return false
    end

    self.items[resolved] = nil

    if self.count.y == resolved:row() or self.count.x == resolved:column() then
        self.count.x = 0
        self.count.y = 0

        for item_index, _ in pairs(self.items) do
            self.count.x = math.max(self.count.x, item_index:column())
            self.count.y = math.max(self.count.y, item_index:row())
        end
    end

    emit(self.dataChanged)

    return true
end

return Model