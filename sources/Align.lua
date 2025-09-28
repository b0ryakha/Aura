local fmt = require("fmt")
require("oop")

---@alias Align.Horizontal "Left" | "Right" | "Center"
---@alias Align.Vertical "Top" | "Bottom" | "Center"

---@class (exact) Align
---@operator call: Align
---@field h Align.Horizontal
---@field v Align.Vertical
local Align = {}

---@param h Align.Horizontal
---@param v? Align.Vertical
---@return Align
function Align:new(h, v)
    local self = create(self, "Align")

    self.h = h
    self.v = v or "Center"
    
    return self
end

setmetatable(Align, { __call = Align.new })

---@return string
function Align:__tostring()
    return fmt("%(h: %, v: %)", type(self), self.h, self.v)
end

return Align