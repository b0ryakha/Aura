local Signal = require("Signal")
local ModelItem = require("ModelItem")
local ModelIndex = require("ModelIndex")

local interface IModel
    items: { ModelIndex : ModelItem }
    count: Vector2

-- public:
    data: function<Self>(Self, ModelIndex, role?: ModelItem.Role): ModelItem.Value

    rowCount: function<Self>(Self): integer
    columnCount: function<Self>(Self): integer

    insert: function<Self>(Self, ModelIndex, ModelItem): boolean
    remove: function<Self>(Self, ModelIndex): boolean

    dataChanged: Signal
end

return IModel