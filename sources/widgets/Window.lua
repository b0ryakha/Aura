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

    local bg_color = self:isEnabled() and theme.background4 or theme.background3
    local outline_color = self:isEnabled() and theme.outline3 or theme.outline2

    render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, bg_color)
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, outline_color)

    self:childsRender()
end

return Window