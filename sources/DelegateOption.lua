require("oop")

---@class (exact) DelegateOption
---@operator call: DelegateOption
---@field private is_selected boolean
---@field private is_hovered boolean
---@field private m_text string
---@field private rect Geometry
---@field private m_font Font
---@field private m_spacing integer
---@field private m_align Align
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
    self.m_text = text
    self.rect = rect
    self.m_font = font
    self.m_spacing = spacing
    self.m_align = align

    return self
end

setmetatable(DelegateOption, { __call = DelegateOption.new })

---@return boolean
function DelegateOption:isSelected()
    return self.is_selected
end

---@return boolean
function DelegateOption:isHovered()
    return self.is_hovered
end

---@return Align
function DelegateOption:align()
    return self.m_align
end

---@return string
function DelegateOption:text()
    return self.m_text
end

---@return Font
function DelegateOption:font()
    return self.m_font
end

---@return integer
function DelegateOption:spacing()
    return self.m_spacing
end

---@return Vector2
function DelegateOption:pos()
    return Vector2:new(self.rect.x, self.rect.y)
end

---@return Vector2
function DelegateOption:size()
    return Vector2:new(self.rect.width, self.rect.height)
end

return DelegateOption