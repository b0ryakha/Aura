require("label")

global enum ButtonState
    "Normal" "Hovered" "Pressed"
end

global record PushButton is IWidget
    label: Label

    is_flat: boolean
    state: ButtonState
    is_pressed: boolean

    clicked: Signal
    pressed: Signal
    released: Signal
end

function PushButton:new(text?: string, size?: Vector2, parent?: IWidget): PushButton
    local self = extends(PushButton, "PushButton", Widget, parent, nil, size)

    self.label = Label:new(text)
    self.label:setAlignment(Align:new("Center"))
    self.label:bindPos(self.m_pos)
    self.label:bindSize(self.m_size)

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

    render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, color, 5)

    if not self.is_flat then
        render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, theme.outline, 5)
    end

    self.label:render()
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