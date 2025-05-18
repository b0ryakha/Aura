require("oop")
require("signal")
require("modelindex")
require("modelitem")

global interface IModel
    items: { ModelIndex : ModelItem }
    count: Vector2

-- public:
    data: function<Self>(Self, ModelIndex, role?: ModelRole): ModelItemValue

    rowCount: function<Self>(Self): integer
    columnCount: function<Self>(Self): integer

    insert: function<Self>(Self, ModelIndex, ModelItem): boolean
    remove: function<Self>(Self, ModelIndex): boolean

    dataChanged: Signal
end

global record Model is IModel end

function Model:new(): Model
    local self = create(Model, "Model")

    self.items = {}
    self.count = Vector2:new(0, 0)

    self.dataChanged = Signal:new()

    return self
end

-- private:
function Model:resolveIndex(index: ModelIndex): ModelIndex
    for resolved, _ in pairs(self.items) do
        if index == resolved then
            return resolved
        end
    end

    return ModelIndex:new()
end

function Model:data(index: ModelIndex, role?: ModelRole): ModelItemValue
    local resolved = self:resolveIndex(index)
    if not resolved:isValid() then
        error(format("%: Cannot find a value at an index: %", type(self), index))
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