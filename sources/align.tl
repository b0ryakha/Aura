local fmt = require("fmt")
require("oop")

local record Align
    enum Horizontal "Left" "Right" "Center" end
    enum Vertical "Top" "Bottom" "Center" end

    h: Horizontal
    v: Vertical

-- force decl:
    metamethod __call: function<Self>(Self, h: Align.Horizontal, v?: Align.Vertical): Align
end

function Align:new(h: Align.Horizontal, v?: Align.Vertical): Align
    local self = create(Align, "Align")

    self.h = h
    self.v = v or h
    
    return self
end

setmetatable(Align, { __call = Align.new })

function Align:__tostring(): string
    return fmt("%(h: %, v: %)", type(self), self.h, self.v)
end

return Align