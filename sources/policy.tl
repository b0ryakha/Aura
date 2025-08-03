local fmt = require("fmt")
require("oop")

local record Policy
    enum Type
        "Fixed" "Minimum" "Maximum"
    end

    h: Type
    v: Type
end

function Policy:new(h: Policy.Type, v?: Policy.Type): Policy
    local self = create(Policy, "Policy")

    self.h = h
    self.v = v or h
    
    return self
end

function Policy:__tostring(): string
    return fmt("%(h: %, v: %)", type(self), self.h, self.v)
end

return Policy