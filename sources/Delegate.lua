local Label = require("Label")
local theme = require("theme")
require("oop")

---@class (exact) Delegate
---@operator call: Delegate
local Delegate = {}

---@return Delegate
function Delegate:new()
    local self = create(Delegate, "Delegate")
    return self
end

setmetatable(Delegate, { __call = Delegate.new })

---@virtual
---@param option DelegateOption
---@param index ModelIndex
function Delegate:paint(option, index)
    local pos = option:pos()
    local size = option:size()

    local label = Label(option:text())
    label:setFont(option:font())
    label:bindPos(pos + option:spacing()) -- fake ref
    label:bindSize(option:size() - option:spacing()) -- fake ref
    label:setAlignment(option:align())

    if option:isHovered() then
        render.rectangle(pos.x, pos.y, size.x, size.y, theme.accent2)
    elseif option:isSelected() then
        label:setColor(theme.foreground)
        render.rectangle(pos.x, pos.y, size.x, size.y, theme.accent3)
    elseif index:row() % 2 == 0 then
        render.rectangle(pos.x, pos.y, size.x, size.y, theme.background5)
    end

    label:render()
end

return Delegate