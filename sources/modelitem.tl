require("oop")

global enum ModelRole
    "Display" "Decoration" "ToolTip" "Font" "Background" "Foreground" "UserData"
end

global type ModelItemValue = any

global record ModelItem
    data: { ModelRole : ModelItemValue }

-- force decl:
    set: function<Self>(Self, ModelRole, ModelItemValue)
end

function ModelItem:new(display: string, decoration?: string, tooltip?: string): ModelItem
    local self = create(ModelItem, "ModelItem")

    self.data = {}

    self:set("Display", display)
    self:set("Decoration", decoration)
    self:set("ToolTip", tooltip)

    return self
end

function ModelItem:set(role: ModelRole, value: ModelItemValue)
    self.data[role] = value
end

function ModelItem:get(role: ModelRole): ModelItemValue
    return self.data[role]
end