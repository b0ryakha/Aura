require("widget")
require("oop")

global record Window is IWidget
    bg_color: Color
    ol_color: Color
    rounding: integer
end

function Window:new(parent: IWidget, size_policy: Policy, size?: Vector2): Window
    local self = extends(Window, "Window", Widget, parent, size_policy, size)

    self.bg_color = CachedColor:new(35, 35, 35)
    self.ol_color = CachedColor:new(70, 70, 70)
    self.rounding = 0

    return self
end

-- override
function Window:render()
    if not self.is_visible then return end

    if self.parent then
        local thickness <const> = 1
        render.rectangle(self.pos.x, self.pos.y, self.size.x, self.size.y, self.ol_color, self.rounding)
        render.rectangle(self.pos.x + thickness, self.pos.y + thickness, self.size.x - thickness * 2, self.size.y - thickness * 2, self.bg_color, self.rounding)
    else
        render.rectangle(self.pos.x, self.pos.y, self.size.x, self.size.y, self.bg_color)
    end

    self:childsRender()
end

function Window:getBackgroundColor(): Color
    return self.bg_color:copy()
end

function Window:setBackgroundColor(color: Color)
    self.bg_color = color
end

function Window:getOutlineColor(): Color
    return self.ol_color:copy()
end

function Window:setOutlineColor(color: Color)
    self.ol_color = color
end