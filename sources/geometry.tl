local fmt = require("fmt")
require("oop")

local record Geometry
    x: number
    y: number
    width: number
    height: number

-- force decl:
    metamethod __call: function<Self>(Self, x: number, y: number, width: number, height: number): Geometry
end

function Geometry:new(x: number, y: number, width: number, height: number): Geometry
    local self = create(Geometry, "Geometry")
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    return self
end

setmetatable(Geometry, { __call = Geometry.new })

function Geometry:__tostring(): string
    return fmt("%(x: %, y: %, w: %, h: %)", type(self), self.x, self.y, self.width, self.height)
end

function Geometry:unpack(): number, number, number, number
    return self.x, self.y, self.width, self.height
end

function Geometry:pos(): Vector2
    return Vector2:new(self.x, self.y)
end

function Geometry:size(): Vector2
    return Vector2:new(self.width, self.height)
end

return Geometry