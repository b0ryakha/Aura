require("oop")

global enum PolicyType
    "Fixed" "Minimum" "Maximum"
end

global record Policy
    h: PolicyType
    v: PolicyType
end

function Policy:new(h: PolicyType, v?: PolicyType): Policy
    local self = create(Policy, "Policy")

    self.h = h
    self.v = v or h
    
    return self
end