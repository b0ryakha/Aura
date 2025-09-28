local Model = require("Model")
local ModelItem = require("ModelItem")
local ModelIndex = require("ModelIndex")

---@class (exact) ListModel: Model
---@operator call: ListModel
local ListModel = {}

---@param values? table<integer, ModelItem.Value>
---@return ListModel
function ListModel:new(values)
    local self = extends(self, "ListModel", Model)

    if values ~= nil then
        for i, value in ipairs(values) do
            self:insert(ModelIndex(i), ModelItem(tostring(value)))
        end
    end

    return self
end

setmetatable(ListModel, { __call = ListModel.new })

return ListModel