require("widget")
require("orientation")

global record Spacer is IWidget
    align_type: Orientation
    thickness: number
end

function Spacer:new(align_type: Orientation, parent?: IWidget): Spacer
    local self = extends(Spacer, "Spacer", Widget, parent, "Maximum")

    self.align_type = align_type
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
function Spacer:resize(m_size: Vector2)
    if not m_size then
        error("Spacer: Cannot set a nil size")
    end

    self.size_policy = Policy:new("Fixed")
    self.m_size = m_size:copy()
    self:update()
end

-- override:
function Spacer:bindSize(m_size: Vector2)
    if not m_size then
        error("Spacer: Cannot bind a nil size")
    end

    self.size_policy = Policy:new("Fixed")
    self.m_size = m_size
    self:update()
end

-- override:
function Spacer:render()
    if not self.is_visible then return end

    local color = CachedColor:new(20, 20, 20)
    
    if self.align_type == "Horizontal" then
        for x = self.m_pos.x, self.m_pos.x + self.m_size.x - self.thickness / 2, self.thickness do
            local x1 = x
            local y1 = (self.m_size.y / 2 + self.m_pos.y)
            local x2 = (x + self.thickness)
            local y2 = (self.m_size.y / 2 + self.m_pos.y + self.thickness)
            render.line(x1, y1, x2, y2, 5, color)
        end
    else -- Vertical:
        for y = self.m_pos.y, self.m_pos.y + self.m_size.y - self.thickness / 2, self.thickness do
            local x1 = (self.m_size.x / 2 + self.m_pos.x)
            local y1 = y
            local x2 = (self.m_size.x / 2 + self.m_pos.x + self.thickness)
            local y2 = (y + self.thickness)
            render.line(x1, y1, x2, y2, 5, color)
        end
    end
end