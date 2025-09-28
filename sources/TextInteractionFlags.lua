local fmt = require("fmt")
require("oop")

---@alias TextInteractionFlag "NoInteraction" | "Selectable" | "Editable" --| "LinksAccessible"
---@alias TextInteractionFlagsRValue table<integer, TextInteractionFlag>

---@class (exact) TextInteractionFlags
---@field private flags TextInteractionFlagsRValue
local TextInteractionFlags = {}

---@param flags TextInteractionFlagsRValue
---@return TextInteractionFlags
function TextInteractionFlags:new(flags)
    local self = create(self, "TextInteractionFlags")

    self.flags = flags
    
    return self
end

setmetatable(TextInteractionFlags, { __call = TextInteractionFlags.new })

---@return string
function TextInteractionFlags:__tostring()
    local result = fmt("%(", self)
    
    for i, flag in ipairs(self.flags) do
        result = result .. flag .. (i < #self.flags and ", " or "")
    end

    return result .. ")"
end

---@param flag TextInteractionFlag
---@return boolean
function TextInteractionFlags:contains(flag)
    for _, v in ipairs(self.flags) do
        if v == flag then
            return true
        end
    end

    return false
end

return TextInteractionFlags