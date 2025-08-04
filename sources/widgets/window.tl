local type IWidget = require("IWidget")
local Widget = require("Widget")
local Policy = require("Policy")
local theme = require("theme")

local record Window is IWidget
    rounding: integer

-- force decl:
    metamethod __call: function<Self>(Self, size_policy?: Policy, size?: Vector2, parent?: IWidget): Window
end

function Window:new(size_policy?: Policy, size?: Vector2, parent?: IWidget): Window
    local self = extends(Window, "Window", Widget, parent, size_policy, size)

    self.rounding = 0

    return self
end

setmetatable(Window, { __call = Window.new })

-- override
--[[
Renders the window.
]]--
function Window:render()
    if not self.is_visible then return end

    local bg_color = self.is_active and theme.background3 or theme.background5

    if self.m_parent then
        local thickness <const> = 1
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, theme.outline2, self.rounding)
        render.rectangle(self.m_pos.x + thickness, self.m_pos.y + thickness, self.m_size.x - thickness * 2, self.m_size.y - thickness * 2, bg_color, self.rounding)
    else
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, bg_color)
    end

    self:childsRender()
end

return Window