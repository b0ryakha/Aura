require("label")

global enum CheckBoxState
    "Normal" "Pressed"
end

global record CheckBox is IWidget
    label: Label
    mark: Sprite

    box_size: Vector2
    offset: number

    bg_color: Color

    state: CheckBoxState
    is_checked: boolean
    lock_press: boolean

    checkStateChanged: Signal

-- force decl:
    updateElements: function<Self>(Self)
end

function CheckBox:new(text?: string, size?: Vector2, parent?: IWidget): CheckBox
    local self = extends(CheckBox, "CheckBox", Widget, parent, nil, nil)

    self.box_size = size or Vector2:new(14, 14)
    self.offset = 5

    self.label = Label:new(text)
    self.label:setAlignment(Align:new("Center"))
    self.label.m_size.y = self.box_size.y

    self.mark = Sprite:new("assets/checkmark.png", 64, 64)
    self.mark:set_color(CachedColor:new(0, 0, 0))

    self.bg_color = CachedColor:new(240, 240, 240)

    self.state = "Normal"
    self.lock_press = false
    self.is_checked = false

    self.checkStateChanged = Signal:new()

    self:bindSize(Vector2:new(self.box_size.x + self.label.m_size.x + self.offset, self.box_size.y))
    self:updateElements()

    return self
end

-- private:
function CheckBox:updateElements()
    self.label:bindPos(Vector2:new(self.m_pos.x + self.box_size.x + self.offset, self.m_pos.y))

    self.mark:set_pos(self.m_pos.x, self.m_pos.y)
    self.mark:set_size(self.box_size.x, self.box_size.y)
end

-- override:
function CheckBox:update()
    if not self.is_active then return end

    if self:isHover() then
        if mouse.is_pressed(button.Left) then
            self.state = "Pressed"

            if not self.lock_press then
                self.lock_press = true
                self.is_checked = not self.is_checked

                self.checkStateChanged:updateData("state", self.is_checked)
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

    render.rectangle(self.m_pos.x, self.m_pos.y, self.box_size.x, self.box_size.y, color, 5)
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.box_size.x, self.box_size.y, 1, CachedColor:new(150, 150, 150), 5)

    if self.is_checked then
        render.sprite(self.mark)
    end

    self.label:render()
end

function CheckBox:isChecked(): boolean
    return self.is_checked
end

function CheckBox:setCheckState(state: boolean)
    self.is_checked = state
end

function CheckBox:text(): string
    return self.label:text()
end

function CheckBox:setText(title: string)
    self.label:setText(title)
end