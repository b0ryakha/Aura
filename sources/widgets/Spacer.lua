local Widget = require("Widget")
local Policy = require("Policy")
local fmt = require("fmt")
local theme = require("theme")

---@class (exact) Spacer: Widget
---@operator call: Spacer
---@field private align_type Orientation
---@field private thickness number
local Spacer = {}

---@param align_type? Orientation
---@param parent? Widget
---@return Spacer
function Spacer:new(align_type, parent)
    local self = extends(Spacer, "Spacer", Widget, parent, Policy("Maximum"))

    self.align_type = align_type or "Horizontal"
    self.thickness = 8

    if self.align_type == "Horizontal" then
        self.m_size.y = self.thickness
    else -- Vertical:
        self.m_size.x = self.thickness
    end

    self:preventFocus()
    self:hide()

    return self
end

setmetatable(Spacer, { __call = Spacer.new })

---@override
---@TODO: override to 'connect'
---@param size Vector2 ref
function Spacer:bindSize(size)
    if not size then
        error(fmt("%: Cannot bind a nil size", type(self)))
    end

    self.size_policy = Policy("Fixed")
    self.m_size = size
    self:update()

    if self.m_size ~= size then
        emit(self.sizeChanged)
    end
end

---@override
function Spacer:render()
    if not self:isVisible() then return end

    if self.align_type == "Horizontal" then
        local x1 = self.m_pos.x
        local y1 = self.m_size.y / 2 + self.m_pos.y
        local x2 = x1 + self.thickness
        local y2 = self.m_size.y / 2 + self.m_pos.y + self.thickness

        render.rectangle(x1, y1 - self.thickness, 1, self.thickness * 3, theme.accent5)

        for x = self.m_pos.x, self.m_pos.x + self.m_size.x - self.thickness / 2, self.thickness do
            x1 = x
            x2 = x1 + self.thickness
            render.line(x1, y1, x2, y2, 1, theme.accent4)
            render.rectangle(x1, y1, 1, self.thickness, theme.accent5)
        end

        render.rectangle(x1 + self.thickness, y1 - self.thickness, 1, self.thickness * 3, theme.accent5)
    else -- Vertical:
        local x1 = self.m_size.x / 2 + self.m_pos.x
        local y1 = self.m_pos.y
        local x2 = self.m_size.x / 2 + self.m_pos.x + self.thickness
        local y2 = y1 + self.thickness
    
        render.rectangle(x1 - self.thickness, y1, self.thickness * 3, 1, theme.accent5)

        for y = self.m_pos.y, self.m_pos.y + self.m_size.y - self.thickness / 2, self.thickness do
            y1 = y
            y2 = y1 + self.thickness
            render.line(x1, y1, x2, y2, 1, theme.accent4)
            render.rectangle(x1, y1, self.thickness, 1, theme.accent5)
        end

        render.rectangle(x1 - self.thickness, y1 + self.thickness, self.thickness * 3, 1, theme.accent5)
    end
end

return Spacer