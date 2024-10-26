require("label")

global enum ButtonState
    "Normal" "Hovered" "Pressed"
end

global record PushButton is IWidget
    text: Label
    bg_color: Color

    is_flat: boolean
    state: ButtonState
    is_pressed: boolean

    clicked: Signal
    pressed: Signal
    released: Signal
end

function PushButton:new(text?: string, size?: Vector2, parent?: IWidget): PushButton
    local self = extends(PushButton, "PushButton", Widget, parent, nil, size)

    self.text = Label:new(text)
    self.text:setAlignment(Align:new("Center"))
    self.text:bindPos(self.m_pos)
    self.text:bindSize(self.m_size)

    self.bg_color = CachedColor:new(240, 240, 240)

    self.is_flat = false
    self.state = "Normal"
    self.is_pressed = false

    self.clicked = Signal:new()
    self.pressed = Signal:new()
    self.released = Signal:new()
    
    return self
end

-- override:
function PushButton:update()
    if not self.is_active then return end

    if self:isHover() then
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

    local color = self.bg_color:copy()
    
    if self.state == "Hovered" then
        color = CachedColor:new(self.bg_color.r + 10, self.bg_color.g + 10, self.bg_color.b + 10)
    end

    if self.state == "Pressed" then
        color = CachedColor:new(self.bg_color.r - 10, self.bg_color.g - 10, self.bg_color.b - 10)
    end

    render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, color, 5)

    if not self.is_flat then
        render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, CachedColor:new(150, 150, 150), 5)
    end

    self.text:render()
end

function PushButton:setColor(color: Color)
    self.bg_color = color
end

function PushButton:isFlat(): boolean
    return self.is_flat
end

function PushButton:setFlat(state: boolean)
    self.is_flat = state
end