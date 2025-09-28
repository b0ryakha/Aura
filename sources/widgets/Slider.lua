local Widget = require("Widget")
local CachedColor = require("CachedColor")
local Signal = require("Signal")
local theme = require("theme")
local fmt = require("fmt")

---@TODO: fix handle going beyond the slider
---@TODO: fix fact that you can drag slider by touching near area (not slider itself)
---@TODO: color the ticks to theme.accent3 if they are at the 'value' level

---@alias Slider.TickPosition
---| "None"
---| "Above"
---| "Left"
---| "Below"
---| "Right"
---| "BothSides"

---@class (exact) Slider: Widget
---@operator call: Slider
---@field private max integer
---@field private min integer
---@field private val integer
---@field private m_percent number
---
---@field private tick_pos Slider.TickPosition
---@field private tick_interval integer
---
---@field private m_orientation Orientation
---@field private is_inverted boolean
---@field private is_dragging boolean
---
---@field private is_debug boolean
---@field private debug_color Color
---
---@field valueChanged Signal
local Slider = {}

---@param size? Vector2
---@param parent? Widget
---@return Slider
function Slider:new(size, parent)
    local self = extends(self, "Slider", Widget, parent, nil, size or Vector2:new(300, 20))

    self.min = 0
    self.max = 100
    self.val = 0
    self.m_percent = 0

    self.tick_pos = "None"
    self.tick_interval = 0

    self.m_orientation = "Horizontal"
    self.is_inverted = false
    self.is_dragging = false

    self.is_debug = false
    self.debug_color = CachedColor:new(cmath.rand_int(150, 255), cmath.rand_int(20, 100), cmath.rand_int(20, 100), 50)

    self.valueChanged = Signal()
    
    return self
end

setmetatable(Slider, { __call = Slider.new })

---@return string
function Slider:__tostring()
    return fmt("%(val: %, min: %, max: %, orientation: %)", type(self), self.val, self.min, self.max, self.m_orientation)
end

---@private
function Slider:updateValue()
    self.m_percent = ((self.val - self.min) / (self.max - self.min)) * 100
end

---@override
function Slider:update(dt)
    if not self:isEnabled() or not self:isVisible() then return end

    local is_bounding = cursor.is_bound(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y)

    if mouse.is_pressed(buttons.Left) or mouse.is_pressed(buttons.Middle) then
        if is_bounding or self.is_dragging then
            local cursor_pos = cursor.get_pos()
            local relative_pos = 0
            local size = (self.m_orientation == "Horizontal") and self.m_size.x or self.m_size.y
            local cursor_pos_value = (self.m_orientation == "Horizontal") and cursor_pos.x or cursor_pos.y
            local normalized_value = (cursor_pos_value - (self.m_orientation == "Horizontal" and self.m_pos.x or self.m_pos.y)) / size * (self.max - self.min)

            if self.m_orientation == "Vertical" then
                relative_pos = self.is_inverted and (self.min + normalized_value) or (self.max - normalized_value)
            else
                relative_pos = self.is_inverted and (self.max - normalized_value) or (self.min + normalized_value)
            end

            self:setValue(cmath.round(relative_pos))
            self.is_dragging = true
        end
    else
        self.is_dragging = false
    end

    local step = 1

    if is_bounding then
        if keyboard.is_pressed(keys.LShift) then
            step = step * 3
        end

        if mouse.is_scrolling_up() then
            self:setValue(cmath.clamp(self.val + step, self.min, self.max))
            self:peekFocus()
        end
        if mouse.is_scrolling_down() then
            self:setValue(cmath.clamp(self.val - step, self.min, self.max))
            self:peekFocus()
        end
    end

    if self:hasFocus() then
        if keyboard.is_pressed(keys.Left) then
            self:setValue(cmath.clamp(self.val - (self.is_inverted and -step or step), self.min, self.max))
        end
        if keyboard.is_pressed(keys.Right) then
            self:setValue(cmath.clamp(self.val + (self.is_inverted and -step or step), self.min, self.max))
        end
        if keyboard.is_pressed(keys.Down) then
            self:setValue(cmath.clamp(self.val - step, self.min, self.max))
        end
        if keyboard.is_pressed(keys.Up) then
            self:setValue(cmath.clamp(self.val + step, self.min, self.max))
        end
    end

    self:parentUpdate()
end

---@override
function Slider:render()
    if not self:isVisible() then return end

    local handle_size = math.min(self.m_size.x, self.m_size.y)
    local handle_pos = Vector2:new(0, 0)
    
    local x, y, w, h = 0, 0, 0, 0
    local bg_x, bg_y, bg_w, bg_h = 0, 0, 0, 0

    local area = (self.m_percent / 100) * (self.m_orientation == "Horizontal" and self.m_size.x or self.m_size.y)

    if not self.is_inverted then
        if self.m_orientation == "Horizontal" then
            w = area
            h = handle_size / 2
            x = self.m_pos.x
            y = self.m_pos.y + h / 2

            bg_w = self.m_size.x
            bg_h = h
            bg_x = x
            bg_y = y

            handle_pos.x = x + w - h
            handle_pos.y = self.m_pos.y
        else -- Vertical:
            w = handle_size / 2
            h = area
            x = self.m_pos.x + self.m_size.x / 2 - w / 2
            y = self.m_pos.y + self.m_size.y - area
            
            bg_w = w
            bg_h = self.m_size.y
            bg_x = x
            bg_y = self.m_pos.y

            handle_pos.x = x - w / 2
            handle_pos.y = y - w
        end
    else
        if self.m_orientation == "Horizontal" then
            w = area
            h = handle_size / 2
            x = self.m_pos.x + self.m_size.x - area
            y = self.m_pos.y + self.m_size.y / 2 - h / 2 

            bg_w = self.m_size.x
            bg_h = h
            bg_x = self.m_pos.x
            bg_y = y

            handle_pos.x = x - h
            handle_pos.y = self.m_pos.y + self.m_size.y / 2 - h
        else -- Vertical:
            w = handle_size / 2
            h = area
            x = self.m_pos.x + w / 2
            y = self.m_pos.y

            bg_w = w
            bg_h = self.m_size.y
            bg_x = x
            bg_y = self.m_pos.y

            handle_pos.x = x - w / 2
            handle_pos.y = y + area - w
        end
    end

    if self.is_debug then
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, self.debug_color)
    end

    render.rectangle(bg_x, bg_y, bg_w, bg_h, self:isEnabled() and theme.background5 or theme.background3)
    render.outline_rectangle(bg_x, bg_y, bg_w, bg_h, 1, self:isEnabled() and theme.outline2 or theme.outline)

    if self:isEnabled() then
        render.rectangle(x, y, w, h, theme.accent2)
        render.outline_rectangle(x, y, w, h, 1, theme.accent3)
    end

    self:renderTicks()

    local outline_color = theme.outline4

    if self:isEnabled() then
        if self:hasFocus() or cursor.is_bound(handle_pos.x, handle_pos.y, handle_size, handle_size) then
            outline_color =  theme.accent3
        end
    else
        outline_color = theme.outline2
    end

    render.circle(handle_pos.x + handle_size / 2, handle_pos.y + handle_size / 2, handle_size, theme.accent, 1, outline_color)
    self:parentRender()
end

---@private
function Slider:renderTicks()
    if self.tick_pos == "None" then return end

    local effective_interval = self.tick_interval
    if effective_interval == 0 then
        effective_interval = math.ceil((self.max - self.min) / 10)
    end

    local tick_count = math.floor((self.max - self.min) / effective_interval)
    local len = 8
    local thick = 2
    local pad = math.min(self.m_size.x, self.m_size.y) / 2
    local color = theme.outline
    local tick_type = self:resolvedTickPosition()

    for i = 0, tick_count do
        local tick_value = self.min + i * effective_interval
        local normalized = (tick_value - self.min) / (self.max - self.min)

        if self.m_orientation == "Horizontal" then
            local x = self.m_pos.x + normalized * self.m_size.x

            if tick_type == "Above" or tick_type == "BothSides" then
                local y = self.m_pos.y + self.m_size.y / 2 - pad * 1.5
                render.line(x, y, x, y - len, thick, color)
            end
            if tick_type == "Below" or tick_type == "BothSides" then
                local y = self.m_pos.y + self.m_size.y / 2 + pad * 1.5
                render.line(x, y, x, y + len, thick, color)
            end
        else -- Vertical:
            local y = self.m_pos.y + normalized * self.m_size.y

            if tick_type == "Left" or tick_type == "BothSides" then
                local x = self.m_pos.x + self.m_size.x / 2 - pad * 1.5
                render.line(x, y, x - len, y, thick, color)
            end
            if tick_type == "Right" or tick_type == "BothSides" then
                local x = self.m_pos.x + self.m_size.x / 2 + pad * 1.5
                render.line(x, y, x + len, y, thick, color)
            end
        end
    end
end

---@private
---@return Slider.TickPosition
function Slider:resolvedTickPosition()
    if self.m_orientation == "Horizontal" then
        if self.tick_pos == "Left" then return "Above" end
        if self.tick_pos == "Right" then return "Below" end
    else -- Vertical:
        if self.tick_pos == "Above" then return "Left" end
        if self.tick_pos == "Below" then return "Right" end
    end

    return self.tick_pos
end

---@param is_debug? boolean
function Slider:turnDebug(is_debug)
    self.is_debug = is_debug or true
end

---@param value integer
function Slider:setValue(value)
    local old = self.val
    self.val = cmath.clamp(value, self.min, self.max)

    if old ~= self.val then
        self:updateValue()
        emit(self.valueChanged)
    end
end

---@return integer
function Slider:value()
    return self.val
end

---@return integer
function Slider:percent()
    return math.floor(self.m_percent)
end

---@return boolean
function Slider:invertedAppearance()
    return self.is_inverted
end

---@param invert boolean
function Slider:setInvertedAppearance(invert)
    self.is_inverted = invert
end

---@return Orientation
function Slider:orientation()
    return self.m_orientation
end

---@param orientation Orientation
function Slider:setOrientation(orientation)
    self.m_orientation = orientation
end

function Slider:reset()
    self:setValue(0)
end

---@param min integer
function Slider:setMinimum(min)
    self.min = min
    self:setValue(min)
end

---@param max integer
function Slider:setMaximum(max)
    self.max = max
    self:setValue(max)
end

---@param tick_interval integer
function Slider:setTickInterval(tick_interval)
    self.tick_interval = tick_interval
end

---@return integer
function Slider:tickInterval()
    return self.tick_interval
end

---@param tick_pos Slider.TickPosition
function Slider:setTickPosition(tick_pos)
    self.tick_pos = tick_pos
end

---@return Slider.TickPosition
function Slider:tickPosition()
    return self.tick_pos
end

---@param min integer
---@param max integer
function Slider:setRange(min, max)
    self.min = min
    self.max = max
    self:setValue(self.val)
end

return Slider