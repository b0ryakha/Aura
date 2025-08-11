local Widget = require("Widget")
local Align = require("Align")
local Signal = require("Signal")
local Label = require("Label")
local fmt = require("fmt")
local theme = require("theme")

---@TODO: fix vertical reduction

---@alias PushButton.State "Normal" | "Hovered" | "Pressed"

---@class (exact) PushButton: Widget
---@operator call: PushButton
---@field private label Label
---
---@field private is_flat boolean
---@field private state PushButton.State
---@field private is_pressed boolean
---
---@field clicked Signal
---@field pressed Signal
---@field released Signal
local PushButton = {}

---@param text? string
---@param size? Vector2
---@param parent? Widget
---@return PushButton
function PushButton:new(text, size, parent)
    self.label = Label(text)

    local self = extends(PushButton, "PushButton", Widget, parent, nil, size or (self.label:measure() + 20))

    self.label:setAlignment(Align("Center"))
    self.label:bindPos(self.m_pos) -- fake ref
    self.label:bindSize(self.m_size)

    self.is_flat = false
    self.state = "Normal"
    self.is_pressed = false

    self.clicked = Signal()
    self.pressed = Signal()
    self.released = Signal()
    
    return self
end

setmetatable(PushButton, { __call = PushButton.new })

---@override
function PushButton:update()
    if not self:isEnabled() or not self:isVisible() then return end

    if self:isHover() or self:hasFocus() then
        if self:isHover() then
            self:setCursor(cursors.Hand)
            self.state = "Hovered"
        else
            self.state = "Normal"
        end

        if (self:isHover() and mouse.is_pressed(buttons.Left)) or keyboard.is_pressed(keys.Space) then
            self.state = "Pressed"
            emit(self.pressed)

            if not self.is_pressed then
                self.is_pressed = true
                emit(self.clicked)
            end
        elseif self.is_pressed then
            self.is_pressed = false
            emit(self.released)
        end
    else
        self.state = "Normal"
    end

    self:widgetUpdate()
end

---@override
function PushButton:render()
    if not self:isVisible() then return end

    local bg_color = theme.accent
    local outline_color = theme.outline3
    
    if not self:isEnabled() then
        outline_color = theme.outline1
    else
        if self.state == "Hovered" then
            outline_color = theme.accent3
        elseif self.state == "Pressed" then
            bg_color = theme.accent2
            outline_color = theme.accent3
        end
    end

    if not self.is_flat or (self.is_flat and self.state == "Pressed") then
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, bg_color, 15)
    end

    if not self.is_flat or (self.state and self.state ~= "Normal") then
        render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, outline_color, 15)
    end

    self.label:render()
    self:widgetRender()
end

---@TODO: override to 'connect'
---@override
---@param pos Vector2 ref
function PushButton:bindPos(pos)
    if not pos then
        error(fmt("%: Cannot bind a nil pos", type(self)))
    end

    self.m_pos = pos
    self.label:bindPos(pos)
    self:update()

    if self.m_pos ~= pos then
        emit(self.posChanged)
    end
end

---@TODO: override to 'connect'
---@override
---@param size Vector2 ref
function PushButton:bindSize(size)
    if not size then
        error(fmt("%: Cannot bind a nil size", type(self)))
    end

    local is_changed = self.m_size ~= size

    self.m_size = size
    self.min_size = size
    if self.m_layout then self.m_layout:bindSize(size) end
    self.label:bindSize(size)

    self:update()

    if is_changed then
        emit(self.sizeChanged)
    end
end

---@return string
function PushButton:text()
    return self.label:text()
end

---@param text string
function PushButton:setText(text)
    self.label:setText(text)
end

---@override
---@param state boolean
function PushButton:setEnabled(state)
    ---@diagnostic disable-next-line: invisible
    self.is_enabled = state
    self.label:setEnabled(state)
end

---@return boolean
function PushButton:isFlat()
    return self.is_flat
end

---@param state boolean
function PushButton:setFlat(state)
    self.is_flat = state
end

return PushButton