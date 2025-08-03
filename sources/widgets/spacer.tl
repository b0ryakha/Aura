local type Orientation = require("Orientation")
local type IWidget = require("IWidget")
local Widget = require("Widget")
local Policy = require("Policy")
local fmt = require("fmt")
local theme = require("theme")

local record Spacer is IWidget
    align_type: Orientation
    thickness: number

-- force decl:
    metamethod __call: function<Self>(Self, align_type?: Orientation, parent?: IWidget): Spacer
end

function Spacer:new(align_type?: Orientation, parent?: IWidget): Spacer
    local self = extends(Spacer, "Spacer", Widget, parent, Policy("Maximum"))

    self.align_type = align_type or "Horizontal"
    self.thickness = 10

    if self.align_type == "Horizontal" then
        self.m_size.y = self.thickness
    else -- Vertical:
        self.m_size.x = self.thickness
    end

    self:hide()

    return self
end

-- override:
function Spacer:bindSize(size: Vector2)
    if not size then
        error(fmt("%: Cannot bind a nil size", type(self)))
    end

    self.size_policy = Policy("Fixed")
    self.m_size = size
    self:update()

    if self.m_size ~= size then
        emit(self.sizeChanged)
    end
end

-- override:
function Spacer:render()
    if not self.is_visible then return end
    
    if self.align_type == "Horizontal" then
        for x = self.m_pos.x, self.m_pos.x + self.m_size.x - self.thickness / 2, self.thickness do
            local x1 = x
            local y1 = (self.m_size.y / 2 + self.m_pos.y)
            local x2 = (x + self.thickness)
            local y2 = (self.m_size.y / 2 + self.m_pos.y + self.thickness)
            render.line(x1, y1, x2, y2, 5, theme.foreground2)
        end
    else -- Vertical:
        for y = self.m_pos.y, self.m_pos.y + self.m_size.y - self.thickness / 2, self.thickness do
            local x1 = (self.m_size.x / 2 + self.m_pos.x)
            local y1 = y
            local x2 = (self.m_size.x / 2 + self.m_pos.x + self.thickness)
            local y2 = (y + self.thickness)
            render.line(x1, y1, x2, y2, 5, theme.foreground2)
        end
    end
end

return Spacer