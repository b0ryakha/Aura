require("label")

global enum CheckBoxState
    "Normal" "Pressed" "Disabled"
end

global record CheckBox is IWidget
    text: Label
    mark: Sprite

    bg_color: Color

    state: CheckBoxState
    is_checked: boolean
    lock_press: boolean

    checkStateChanged: Signal

-- force decl:
    updateElements: function<Self>(Self)
end

function CheckBox:new(text?: string, size?: Vector2, parent?: IWidget): CheckBox
    local self = extends(CheckBox, "CheckBox", Widget, parent, nil, size or Vector2:new(16, 16))

    self.text = Label:new(text)
    self.text:setAlignment(Align:new("Center"))
    self.text:resize(Vector2:new(self.text:size().x, self.m_size.y))

    self.mark = Sprite:new("assets/checkmark.png", 64, 64)
    self.mark:set_color(CachedColor:new(0, 0, 0))

    self.bg_color = CachedColor:new(240, 240, 240)

    self.state = "Normal"
    self.lock_press = false
    self.is_checked = false

    self.checkStateChanged = Signal:new()

    self:updateElements()

    return self
end

-- private:
function CheckBox:updateElements()
    self.text:bindPos(Vector2:new(self.m_pos.x + self.m_size.x + 5, self.m_pos.y))

    self.mark:set_pos(self.m_pos.x, self.m_pos.y)
    self.mark:set_size(self.m_size.x, self.m_size.y)
end

-- override:
function CheckBox:update()
    if self.state == "Disabled" then return end

    if self:isHover() then
        if mouse.is_pressed(button.Left) then
            self.state = "Pressed"

            if not self.lock_press then
                self.lock_press = true
                self.is_checked = not self.is_checked
                emit(self.checkStateChanged)
            end
        elseif self.lock_press then
            self.lock_press = false
            self.state = "Normal"
        end
    else
        self.state = "Normal"
    end

    self:updateElements()
end

-- override:
function CheckBox:render()
    if not self.is_visible then return end

    local color = self.bg_color:copy()
    
    if self.state == "Pressed" then
        color = CachedColor:new(self.bg_color.r - 20, self.bg_color.g - 20, self.bg_color.b - 20)
    end

    if self.state == "Disabled" then
        color = CachedColor:new(self.bg_color.r, self.bg_color.g, self.bg_color.b, 150)
    end

    render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, color, 5)
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, CachedColor:new(150, 150, 150), 5)

    if self.is_checked then
        render.sprite(self.mark)
    end

    self.text:render()
end

function CheckBox:enable()
    self.state = "Normal"
end

function CheckBox:disable()
    self.state = "Disabled"
end

function CheckBox:isChecked(): boolean
    return self.is_checked
end

function CheckBox:setCheckState(state: boolean)
    self.is_checked = state
end