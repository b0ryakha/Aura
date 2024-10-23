require("widget")
require("oop")

global enum SpacerType
    "Horizontal" "Vertical"
end

global record Spacer is IWidget
    is_debug: boolean
    align_type: SpacerType
    debug_color: Color
    thickness: number
end

function Spacer:new(parent: IWidget, align_type: SpacerType): Spacer
    local self = extends(Spacer, "Spacer", Widget, parent, "Maximum")

    self.is_debug = false
    self.debug_color = CachedColor:new(20, 20, 20)
    self.align_type = align_type
    self.thickness = 10

    if self.align_type == "Horizontal" then
        self.size.y = self.thickness
    else -- Vertical:
        self.size.x = self.thickness
    end

    return self
end

-- override:
function Spacer:setSize(size: Vector2)
    if not size then
        error("Spacer: Cannot set a nil size")
    end

    self.size_policy = Policy:new("Fixed")
    self.size = size
    self:update()
end

-- override:
function Spacer:render()
    if not self:isVisible() then return end
    if not self.is_debug then return end
    
    if self.align_type == "Horizontal" then
        for x = self.pos.x, self.pos.x + self.size.x - self.thickness / 2, self.thickness do
            local x1 = x as integer
            local y1 = (self.size.y / 2 + self.pos.y) as integer
            local x2 = (x + self.thickness) as integer
            local y2 = (self.size.y / 2 + self.pos.y + self.thickness) as integer
            render.line(x1, y1, x2, y2, 5, self.debug_color)
        end
    else -- Vertical:
        for y = self.pos.y, self.pos.y + self.size.y - self.thickness / 2, self.thickness do
            local x1 = (self.size.x / 2 + self.pos.x) as integer
            local y1 = y as integer
            local x2 = (self.size.x / 2 + self.pos.x + self.thickness) as integer
            local y2 = (y + self.thickness) as integer
            render.line(x1, y1, x2, y2, 5, self.debug_color)
        end
    end
end

function Spacer:turnDebug(is_debug?: boolean)
    self.is_debug = is_debug == nil and true or is_debug
end