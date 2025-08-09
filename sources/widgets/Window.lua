local Widget = require("Widget")
local theme = require("theme")

---@class (exact) Window: Widget
---@operator call: Window
---@field private rounding integer
local Window = {}

---@param size_policy? Policy
---@param size? Vector2
---@param parent? Widget
---@return Window
function Window:new(size_policy, size, parent)
    local self = extends(Window, "Window", Widget, parent, size_policy, size)

    self.rounding = 0
    self:preventFocus()

    return self
end

setmetatable(Window, { __call = Window.new })

---@override
function Window:render()
    if not self:isVisible() then return end

    local bg_color = self:isActive() and theme.background3 or theme.background5

    if self.m_parent then
        local thickness = 1
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, theme.outline2, self.rounding)
        render.rectangle(self.m_pos.x + thickness, self.m_pos.y + thickness, self.m_size.x - thickness * 2, self.m_size.y - thickness * 2, bg_color, self.rounding)
    else
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, bg_color)
    end

    self:childsRender()
end

return Window