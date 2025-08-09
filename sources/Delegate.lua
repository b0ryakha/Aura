local Label = require("Label")
local theme = require("theme")
require("oop")

---@class (exact) Delegate
---@operator call: Delegate
---@field private cached_labels table<string, Label>
local Delegate = {}

---@return Delegate
function Delegate:new()
    local self = create(Delegate, "Delegate")

    self.cached_labels = {}

    return self
end

setmetatable(Delegate, { __call = Delegate.new })

function Delegate:clearCache()
    self.cached_labels = {}
end

---@virtual
---@param option DelegateOption
---@param index ModelIndex
function Delegate:paint(option, index)
    local hash = option.text .. tostring(option.rect) .. tostring(option.align)
    if self.cached_labels[hash] == nil then
        local label = Label(option.text)
        label:setFont(option.font)
        label:bindPos(option.rect:pos() + option.spacing)
        label:bindSize(option.rect:size() - option.spacing)
        label:setAlignment(option.align)

        self.cached_labels[hash] = label
    end

    if option.is_hovered then
        render.gradient(option.rect.x, option.rect.y, option.rect.width, option.rect.height, theme.light_accent, theme.light_accent, theme.accent, theme.accent)
    elseif option.is_selected then
        render.gradient(option.rect.x, option.rect.y, option.rect.width, option.rect.height, theme.accent, theme.accent, theme.dark_accent, theme.dark_accent)
    elseif index:row() % 2 == 0 then
        render.rectangle(option.rect.x, option.rect.y, option.rect.width, option.rect.height, theme.background)
    end

    self.cached_labels[hash]:render()
end

return Delegate