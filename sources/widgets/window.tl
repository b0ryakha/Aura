require("widget")

global record Window is IWidget
    bg_color: Color
    ol_color: Color
    rounding: integer
end

function Window:new(size_policy?: Policy, size?: Vector2, parent?: IWidget): Window
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
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, self.ol_color, self.rounding)
        render.rectangle(self.m_pos.x + thickness, self.m_pos.y + thickness, self.m_size.x - thickness * 2, self.m_size.y - thickness * 2, self.bg_color, self.rounding)
    else
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, self.bg_color)
    end

    self:childsRender()
end

function Window:backgroundColor(): Color
    return self.bg_color:copy()
end

function Window:setBackgroundColor(color: Color)
    self.bg_color = color
end

function Window:outlineColor(): Color
    return self.ol_color:copy()
end

function Window:setOutlineColor(color: Color)
    self.ol_color = color
end