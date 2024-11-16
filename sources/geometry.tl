require("oop")

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