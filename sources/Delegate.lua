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
    local label = Label(option.text)
    label:setFont(option.font)
    label:bindPos(option.rect:pos() + option.spacing)
    label:bindSize(option.rect:size() - option.spacing)
    label:setAlignment(option.align)

    if option.is_hovered then
        render.rectangle(option.rect.x, option.rect.y, option.rect.width, option.rect.height, theme.accent2)
    elseif option.is_selected then
        label:setColor(theme.foreground)
        render.rectangle(option.rect.x, option.rect.y, option.rect.width, option.rect.height, theme.accent3)
    elseif index:row() % 2 == 0 then
        render.rectangle(option.rect.x, option.rect.y, option.rect.width, option.rect.height, theme.background5)
    end

    label:render()
end

return Delegate