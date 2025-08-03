
local ModelIndex = require("ModelIndex")
local DelegateOption = require("DelegateOption")
local type IDelegate = require("IDelegate")
local Label = require("Label")
local theme = require("theme")
require("oop")

local record Delegate is IDelegate
    cached_labels: { string : Label }
end

function Delegate:new(): Delegate
    local self = create(Delegate, "Delegate")

    self.cached_labels = {}

    return self
end

function Delegate:clear_cache()
    self.cached_labels = {}
end

-- override:
function Delegate:paint(option: DelegateOption, index: ModelIndex)
    local hash = option.text .. tostring(option.rect) .. tostring(option.align)
    if self.cached_labels[hash] == nil then
        local label = Label:new(option.text)
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