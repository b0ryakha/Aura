require("widget")
require("oop")
require("label")
require("policy")

global enum ButtonState
    "Normal" "Hovered" "Pressed" "Disabled"
end

global record PushButton is IWidget
    text: Label
    bg_color: Color

    state: ButtonState
    is_pressed: boolean

    clicked: Signal
    pressed: Signal
    released: Signal
end

function PushButton:new(parent: IWidget, text?: string, policy?: Policy, size?: Vector2): PushButton
    local self = extends(PushButton, "PushButton", Widget, parent, policy, size)

    self.text = Label:new(nil, text)
    self.text:setAlign(Align:new("Center"))
    self.text:setPos(self.pos) -- by ref
    self.text:setSize(self.size) -- by ref

    self.bg_color = CachedColor:new(250, 250, 250)

    self.state = "Normal"
    self.is_pressed = false

    self.clicked = Signal:new()
    self.pressed = Signal:new()
    self.released = Signal:new()
    
    return self
end

-- override:
function PushButton:update()
    if self.state == "Disabled" then return end

    if cursor.is_bound(self.pos.x, self.pos.y, self.size.x, self.size.y) then
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
        color = CachedColor:new(self.bg_color.r - 10, self.bg_color.g - 10, self.bg_color.b - 10)
    end

    if self.state == "Pressed" then
        color = CachedColor:new(self.bg_color.r - 20, self.bg_color.g - 20, self.bg_color.b - 20)
    end

    if self.state == "Disabled" then
        color = CachedColor:new(self.bg_color.r, self.bg_color.g, self.bg_color.b, 150)
    end

    render.rectangle(self.pos.x, self.pos.y, self.size.x, self.size.y, color, 5)
    render.outline_rectangle(self.pos.x, self.pos.y, self.size.x, self.size.y, 1, CachedColor:new(150, 150, 150), 5)
    self.text:render()
end

function PushButton:setColor(color: Color)
    self.bg_color = color
end

function PushButton:enable()
    self.state = "Normal"
end

function PushButton:disable()
    self.state = "Disabled"
end