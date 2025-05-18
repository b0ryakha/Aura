require("model")

global record ListModel is IModel end

function ListModel:new(values?: { ModelItemValue }): ListModel
    local self = extends(ListModel, "ListModel", Model)

    if values ~= nil then
        for i, value in ipairs(values) do
            self:insert(ModelIndex:new(i), ModelItem:new(tostring(value)))
        end
    end

    return self
end