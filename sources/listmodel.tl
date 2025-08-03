local type IModel = require("IModel")
local Model = require("Model")
local ModelItem = require("ModelItem")
local ModelIndex = require("ModelIndex")

local record ListModel is IModel end

function ListModel:new(values?: { ModelItem.Value }): ListModel
    local self = extends(ListModel, "ListModel", Model)

    if values ~= nil then
        for i, value in ipairs(values) do
            self:insert(ModelIndex:new(i), ModelItem:new(tostring(value)))
        end
    end

    return self
end

return ListModel