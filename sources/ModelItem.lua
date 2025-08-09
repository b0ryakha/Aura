require("oop")

---@alias ModelItem.Value any
---@alias ModelItem.Role "Display" | "Decoration" | "ToolTip" | "Font" | "Background" | "Foreground" | "UserData"

---@class (exact) ModelItem
---@operator call: ModelItem
---@field private data table<ModelItem.Role, ModelItem.Value>
local ModelItem = {}

---@param display string
---@param decoration? string
---@param tooltip? string
---@return ModelItem
function ModelItem:new(display, decoration, tooltip)
    local self = create(ModelItem, "ModelItem")

    self.data = {}

    self:set("Display", display)
    self:set("Decoration", decoration)
    self:set("ToolTip", tooltip)

    return self
end

setmetatable(ModelItem, { __call = ModelItem.new })

---@param role ModelItem.Role
---@param value ModelItem.Value
function ModelItem:set(role, value)
    self.data[role] = value
end

---@param role ModelItem.Role
---@return ModelItem.Value
function ModelItem:get(role)
    return self.data[role]
end

return ModelItem