local fmt = require("fmt")
require("oop")

---@class (exact) Margins
---@operator call: Margins
---@field left number
---@field right number
---@field top number
---@field bottom number
local Margins = {}

---@param left number
---@param right number
---@param top number
---@param bottom number
---@return Margins
function Margins:new(left, right, top, bottom)
    local self = create(Margins, "Margins")
    
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom
    
    return self
end

setmetatable(Margins, { __call = Margins.new })

---@return Margins
function Margins:copy()
    return Margins(self.left, self.right, self.top, self.bottom)
end

---@return string
function Margins:__tostring()
    return fmt("%(l: %, r: %, t: %, b: %)", type(self), self.left, self.right, self.top, self.bottom)
end

return Margins