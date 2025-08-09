require("oop")

---@class (exact) DelegateOption
---@operator call: DelegateOption
---@field is_selected boolean
---@field is_hovered boolean
---@field text string
---@field rect Geometry
---@field font Font
---@field spacing integer
---@field align Align
local DelegateOption = {}

---@param is_selected boolean
---@param is_hovered boolean
---@param text string
---@param rect Geometry
---@param font Font
---@param spacing integer
---@param align Align
---@return DelegateOption
function DelegateOption:new(is_selected, is_hovered, text, rect, font, spacing, align)
    local self = create(DelegateOption, "DelegateOption")

    self.is_selected = is_selected
    self.is_hovered = is_hovered
    self.text = text
    self.rect = rect
    self.font = font
    self.spacing = spacing
    self.align = align

    return self
end

setmetatable(DelegateOption, { __call = DelegateOption.new })

return DelegateOption