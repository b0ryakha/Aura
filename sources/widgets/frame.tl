require("widget")
require("oop")

global record Frame is IWidget
    
end

function Frame:new(parent: IWidget, size_policy?: Policy, size?: Vector2): Frame
    local self = extends(Frame, "Frame", Widget, parent, size_policy, size)

    return self
end

-- override:
function Frame:render()
    if not self.is_visible then return end

    render.outline_rectangle(
        self.pos.x as integer,
        self.pos.y as integer,
        self.size.x as integer,
        self.size.y as integer,
        1,
        CachedColor:new(150, 150, 150),
        1
    )
end