local fmt = require("fmt")
require("oop")

local record Margins
    left: number
    right: number
    top: number
    bottom: number

-- force decl:
    metamethod __call: function<Self>(Self, left: number, right: number, top: number, bottom: number): Margins
end
    
function Margins:new(left: number, right: number, top: number, bottom: number): Margins
    local self = create(Margins, "Margins")
    
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom
    
    return self
end

function Margins:copy(): Margins
    return Margins(self.left, self.right, self.top, self.bottom)
end

function Margins:__tostring(): string
    return fmt("%(l: %, r: %, t: %, b: %)", type(self), self.left, self.right, self.top, self.bottom)
end

return Margins