local Widget = require("Widget")
local Align = require("Align")
local Signal = require("Signal")
local Label = require("Label")
local theme = require("theme")

---@class (exact) ProgressBar: Widget
---@operator call: ProgressBar
---@field private label Label
---@field private m_format string
---
---@field private max integer
---@field private min integer
---@field private val integer
---@field private m_percent integer
---
---@field private m_orientation Orientation
---@field private is_inverted boolean
---
---@field valueChanged Signal
local ProgressBar = {}

---@param size? Vector2
---@param parent? Widget
---@return ProgressBar
function ProgressBar:new(size, parent)
    local self = extends(ProgressBar, "ProgressBar", Widget, parent, nil, size)

    self.label = Label()
    self.label:setAlignment(Align("Center"))
    self.label:bindPos(self.m_pos)
    self.label:bindSize(self.m_size)
    self:resetFormat()

    self.min = 0
    self.max = 100
    self.val = 0
    self.m_percent = 0
    self.m_orientation = "Horizontal"
    self.is_inverted = false

    self.valueChanged = Signal()
    
    return self
end

setmetatable(ProgressBar, { __call = ProgressBar.new })

---@private
---@param fmt string can contains: 'p' - percent, 'v' - value, 'm' - max
---@return string
function ProgressBar:formattedText(fmt)
    local values = {
        ['p'] = self.m_percent,
        ['v'] = self.val,
        ['m'] = self.max
    }

    return (fmt:gsub("%%[pvm]", function(match)
        local k = match:sub(2, 2)
        local v = values[k]
        return v and tostring(v) or match
    end))
end

---@override
function ProgressBar:update()
    if not self:isActive() then return end

    self.m_percent = math.floor(((self.val - self.min) / (self.max - self.min)) * 100)
    self.label:setText(self:formattedText(self.m_format))
end

---@override
function ProgressBar:render()
    if not self:isVisible() then return end

    render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, theme.default)
    
    local x = self.m_pos.x
    local y = self.m_pos.y
    local w = (self.m_percent / 100) * self.m_size.x
    local h = self.m_size.y

    if self.is_inverted then
        if self.m_orientation == "Horizontal" then
            x = x + self.m_size.x - (self.m_percent / 100) * self.m_size.x
            w = (self.m_percent / 100) * self.m_size.x
        else -- Vertical:
            w = self.m_size.x
            h = (self.m_percent / 100) * self.m_size.y
        end
    else
        if self.m_orientation == "Vertical" then
            y = y + h - (self.m_percent / 100) * self.m_size.y
            w = self.m_size.x
            h = (self.m_percent / 100) * self.m_size.y
        end
    end

    render.gradient(x, y, w, h, theme.accent, theme.accent, theme.dark_accent, theme.dark_accent)
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, theme.outline)

    self.label:render()
end

---@return boolean
function ProgressBar:invertedAppearance()
    return self.is_inverted
end

---@param invert boolean
function ProgressBar:setInvertedAppearance(invert)
    self.is_inverted = invert
end

---@return Orientation
function ProgressBar:orientation()
    return self.m_orientation
end

---@param orientation Orientation
function ProgressBar:setOrientation(orientation)
    self.m_orientation = orientation
end

---@param value integer
function ProgressBar:setValue(value)
    local old = self.val
    self.val = cmath.clamp(value, self.min, self.max)

    if old ~= self.val then
        emit(self.valueChanged)
    end
end

---@return integer
function ProgressBar:value()
    return self.val
end

---@return integer
function ProgressBar:percent()
    return self.m_percent
end

function ProgressBar:reset()
    self.val = 0
    self.m_percent = 0
end

---@param min integer
function ProgressBar:setMinimum(min)
    self.min = min
    self:setValue(self.val)
end

---@param max integer
function ProgressBar:setMaximum(max)
    self.max = max
    self:setValue(self.val)
end

---@param min integer
---@param max integer
function ProgressBar:setRange(min, max)
    self.min = min
    self.max = max
    self:setValue(self.val)
end

---@return string
function ProgressBar:fmt()
    return self.m_format
end

---@param fmt string can contains: 'p' - percent, 'v' - value, 'm' - max
function ProgressBar:setFormat(fmt)
    self.m_format = fmt
end

function ProgressBar:resetFormat()
    self:setFormat("%p%")
end

return ProgressBar