local type IModel = require("IModel")
local Model = require("Model")
local ModelItem = require("ModelItem")
local ModelIndex = require("ModelIndex")

local record ListModel is IModel
-- force decl:
    metamethod __call: function<Self>(Self, values?: { ModelItem.Value }): ListModel
end

function ListModel:new(values?: { ModelItem.Value }): ListModel
    local self = extends(ListModel, "ListModel", Model)

    if values ~= nil then
        for i, value in ipairs(values) do
            self:insert(ModelIndex(i), ModelItem(tostring(value)))
        end
    end

    return self
end

return ListModel