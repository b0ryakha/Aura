local TextEdit = require("TextEdit")
local fmt = require("fmt")

---@class (exact) LineEdit: TextEdit
---@operator call: LineEdit
local LineEdit = {}

---@param placeholder_text? string
---@param size? Vector2
---@param parent? Widget
---@return LineEdit
function LineEdit:new(placeholder_text, size, parent)
    local self = extends(self, "LineEdit", TextEdit, placeholder_text, size, parent)

    self:setLineLimit(1)

    return self
end

setmetatable(LineEdit, { __call = LineEdit.new })

return LineEdit