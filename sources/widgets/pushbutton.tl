local type IWidget = require("IWidget")
local Widget = require("Widget")
local Align = require("Align")
local Signal = require("Signal")
local Label = require("Label")
local fmt = require("fmt")
local theme = require("theme")

local record PushButton is IWidget
    enum State
        "Normal" "Hovered" "Pressed"
    end

    label: Label

    is_flat: boolean
    state: State
    is_pressed: boolean

    clicked: Signal
    pressed: Signal
    released: Signal

-- force decl:
    metamethod __call: function<Self>(Self, text?: string, size?: Vector2, parent?: IWidget): PushButton
end

function PushButton:new(text?: string, size?: Vector2, parent?: IWidget): PushButton
    local self = extends(PushButton, "PushButton", Widget, parent, nil, size)

    self.label = Label(text)
    self.label:setAlignment(Align("Center"))
    self.label:bindPos(self.m_pos) -- fake ref
    self.label:bindSize(self.m_size) -- fake ref

    self.is_flat = false
    self.state = "Normal"
    self.is_pressed = false

    self.clicked = Signal()
    self.pressed = Signal()
    self.released = Signal()
    
    return self
end

setmetatable(PushButton, { __call = PushButton.new })

-- override:
function PushButton:update()
    if not self.is_active then return end

    if self:isHover() then
        self:setCursor(cursor_type.Hand)
        self.state = "Hovered"

        if mouse.is_pressed(button.Left) then
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
end

-- override:
function PushButton:render()
    if not self.is_visible then return end

    local color = theme.default
    
    if not self.is_active then
        color = theme.background2
    else
        if self.state == "Hovered" then
            color = theme.hovered
        end
    
        if self.state == "Pressed" then
            color = theme.pressed
        end
    end

    render.gradient(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, color, color, theme.pressed, theme.pressed)

    if not self.is_flat then
        render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, theme.outline)
    end

    self.label:render()
end

-- override:
function PushButton:bindPos(pos: Vector2)
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

-- override:
function PushButton:bindSize(size: Vector2)
    if not size then
        error(fmt("%: Cannot bind a nil size", type(self)))
    end

    self.m_size = size
    self.min_size = size
    if self.m_layout then self.m_layout:bindSize(size) end
    self.label:bindSize(size)

    self:update()

    if self.m_size ~= size then
        emit(self.sizeChanged)
    end
end

function PushButton:text(): string
    return self.label:text()
end

function PushButton:setText(text: string)
    self.label:setText(text)
end

-- override:
function PushButton:setActive(state: boolean)
    self.is_active = state
    self.label:setActive(self.is_active)
end

function PushButton:isFlat(): boolean
    return self.is_flat
end

function PushButton:setFlat(state: boolean)
    self.is_flat = state
end

return PushButton