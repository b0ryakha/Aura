local fmt = require("fmt")
require("oop")

---@class (exact) Policy
---@operator call: Policy
---@field h Policy.Type
---@field v Policy.Type
local Policy = {}

---@alias Policy.Type "Fixed" | "Minimum" | "Maximum"

---@param h Policy.Type
---@param v? Policy.Type
---@return Policy
function Policy:new(h, v)
    local self = create(self, "Policy")

    self.h = h
    self.v = v or h
    
    return self
end

setmetatable(Policy, { __call = Policy.new })

---@return string
function Policy:__tostring()
    return fmt("%(h: %, v: %)", type(self), self.h, self.v)
end

return Policy