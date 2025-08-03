require("oop")

local record ModelItem
    type Value = any
    enum Role
        "Display" "Decoration" "ToolTip" "Font" "Background" "Foreground" "UserData"
    end

    data: { Role : Value }

-- force decl:
    metamethod __call: function<Self>(Self, display: string, decoration?: string, tooltip?: string): ModelItem
    set: function<Self>(Self, Role, Value)
end

function ModelItem:new(display: string, decoration?: string, tooltip?: string): ModelItem
    local self = create(ModelItem, "ModelItem")

    self.data = {}

    self:set("Display", display)
    self:set("Decoration", decoration)
    self:set("ToolTip", tooltip)

    return self
end

function ModelItem:set(role: ModelItem.Role, value: ModelItem.Value)
    self.data[role] = value
end

function ModelItem:get(role: ModelItem.Role): ModelItem.Value
    return self.data[role]
end

return ModelItem