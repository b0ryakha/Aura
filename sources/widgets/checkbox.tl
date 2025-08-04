local type IWidget = require("IWidget")
local Widget = require("Widget")
local Align = require("Align")
local Signal = require("Signal")
local Label = require("Label")
local Image = require("Image")
local theme = require("theme")

--TODO: check by SPACE key or add bind system for widgets
local record CheckBox is IWidget
    enum State
        "Normal" "Pressed"
    end

    label: Label
    mark: Image

    box_size: Vector2
    offset: number
    mutable_offset: number

    state: State
    is_checked: boolean
    lock_press: boolean

    checkStateChanged: Signal

-- force decl:
    metamethod __call: function<Self>(Self, text?: string, size?: Vector2, parent?: IWidget): CheckBox
    updateElements: function<Self>(Self)
end

function CheckBox:new(text?: string, size?: Vector2, parent?: IWidget): CheckBox
    local self = extends(CheckBox, "CheckBox", Widget, parent, nil, nil)

    self.box_size = size or Vector2:new(14, 14)
    self.offset = 5
    self.mutable_offset = self.offset

    self.label = Label(text)
    self.label:setAlignment(Align("Center"))
    self.label.m_size.y = self.box_size.y

    self.mark = Image("assets/checkmark.png", Vector2:new(64, 64))
    self.mark:setColor(theme.foreground)

    self.state = "Normal"
    self.lock_press = false
    self.is_checked = false

    self.checkStateChanged = Signal()

    self:bindSize(Vector2:new(self.box_size.x + self.label.m_size.x + self.mutable_offset, self.box_size.y))
    self:updateElements()

    return self
end

setmetatable(CheckBox, { __call = CheckBox.new })

-- private:
function CheckBox:updateElements()
    self.label:bindPos(Vector2:new(self.m_pos.x + self.box_size.x + self.mutable_offset, self.m_pos.y))

    self.mark:setPos(self.m_pos)
    self.mark:resize(self.box_size)
end

-- override:
function CheckBox:update()
    if not self.is_active then return end

    if self:isHover() then
        self:setCursor(cursor_type.Hand)

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

    local color = theme.default

    if not self.is_active then
        color = theme.background2
    elseif self.state == "Pressed" then
        color = theme.pressed
    end

    render.rectangle(self.m_pos.x, self.m_pos.y, self.box_size.x, self.box_size.y, color, 5)
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.box_size.x, self.box_size.y, 1, theme.outline, 5)

    if self.is_checked then
        self.mark:render()
    end

    self.label:render()
end

-- override:
function CheckBox:setActive(state: boolean)
    self.is_active = state

    self.label:setActive(self.is_active)
    self.mark:setActive(self.is_active)
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
    self.mutable_offset = title == "" and 0 or self.offset
end

return CheckBox