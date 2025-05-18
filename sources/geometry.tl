require("oop")
require("format")

global record Geometry
    x: number
    y: number
    width: number
    height: number
end

function Geometry:new(x: number, y: number, width: number, height: number): Geometry
    local self = create(Geometry, "Geometry")
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    return self
end

function Geometry:__tostring(): string
    return format("%(x: %, y: %, w: %, h: %)", type(self), self.x, self.y, self.width, self.height)
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