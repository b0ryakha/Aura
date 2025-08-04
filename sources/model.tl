local type IModel = require("IModel")
local ModelItem = require("ModelItem")
local ModelIndex = require("ModelIndex")
local Signal = require("Signal")
local fmt = require("fmt")
require("oop")

local record Model is IModel
-- force decl:
    metamethod __call: function<Self>(Self): Model
end

function Model:new(): Model
    local self = create(Model, "Model")

    self.items = {}
    self.count = Vector2:new(0, 0)

    self.dataChanged = Signal()

    return self
end

setmetatable(Model, { __call = Model.new })

-- private:
function Model:resolveIndex(index: ModelIndex): ModelIndex
    for resolved, _ in pairs(self.items) do
        if index == resolved then
            return resolved
        end
    end

    return ModelIndex()
end

function Model:data(index: ModelIndex, role?: ModelItem.Role): ModelItem.Value
    local resolved = self:resolveIndex(index)
    if not resolved:isValid() then
        error(fmt("%: Cannot find a value at an index: %", type(self), index))
    end

    return self.items[resolved]:get(role or "Display")
end

function Model:rowCount(): integer
    return self.count.y as integer
end

function Model:columnCount(): integer
    return self.count.x as integer
end

function Model:insert(index: ModelIndex, item: ModelItem): boolean
    if not index:isValid() or self:resolveIndex(index):isValid() then
        return false
    end

    self.items[index] = item
    self.count.x = math.max(self.count.x, index:column())
    self.count.y = math.max(self.count.x, index:row())

    emit(self.dataChanged)

    return true
end

function Model:remove(index: ModelIndex): boolean
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