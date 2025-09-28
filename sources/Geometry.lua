local fmt = require("fmt")
require("oop")

---@class (exact) Geometry
---@operator call: Geometry
---@field x number
---@field y number
---@field width number
---@field height number
local Geometry = {}

---@param x number
---@param y number
---@param width number
---@param height number
---@return Geometry
function Geometry:new(x, y, width, height)
    local self = create(self, "Geometry")
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    return self
end

setmetatable(Geometry, { __call = Geometry.new })

---@return string
function Geometry:__tostring()
    return fmt("%(x: %, y: %, w: %, h: %)", type(self), self.x, self.y, self.width, self.height)
end

---@return number, number, number, number
function Geometry:unpack()
    return self.x, self.y, self.width, self.height
end

---@return Vector2 
function Geometry:pos()
    return Vector2:new(self.x, self.y)
end

---@return Vector2 
function Geometry:size()
    return Vector2:new(self.width, self.height)
end

return Geometry