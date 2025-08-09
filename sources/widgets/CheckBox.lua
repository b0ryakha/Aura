local Widget = require("Widget")
local Align = require("Align")
local Signal = require("Signal")
local Label = require("Label")
local Image = require("Image")
local theme = require("theme")

---@alias CheckBox.State "Normal" | "Pressed"

---@class (exact) CheckBox: Widget
---@operator call: CheckBox
---@field private label Label
---@field private mark Image
---
---@field private box_size Vector2
---@field private offset number
---@field private mutable_offset number
---
---@field private state CheckBox.State
---@field private is_checked boolean
---@field private lock_press boolean
---
---@field checkStateChanged Signal
local CheckBox = {}

---@param text? string
---@param size? Vector2
---@param parent? Widget
---@return CheckBox
function CheckBox:new(text, size, parent)
    local self = extends(CheckBox, "CheckBox", Widget, parent, nil, nil)

    self.box_size = size or Vector2:new(14, 14)
    self.offset = 5
    self.mutable_offset = self.offset

    self.label = Label(text)
    self.label:setAlignment(Align("Center"))
    self.label.m_size.y = self.box_size.y
    self.label:redirectFocus(self)

    self.mark = Image("assets/checkmark.png", Vector2:new(64, 64))
    self.mark:setColor(theme.foreground)
    self.mark:preventFocus()

    self.state = "Normal"
    self.lock_press = false
    self.is_checked = false

    self.checkStateChanged = Signal()

    self:bindSize(Vector2:new(self.box_size.x + self.label.m_size.x + self.mutable_offset, self.box_size.y))
    self:updateElements()

    return self
end

setmetatable(CheckBox, { __call = CheckBox.new })

---@private
function CheckBox:updateElements()
    self.label:bindPos(Vector2:new(self.m_pos.x + self.box_size.x + self.mutable_offset, self.m_pos.y))

    self.mark:setPos(self.m_pos)
    self.mark:resize(self.box_size)
end

---@override
function CheckBox:update()
    if not self:isActive() then return end

    if self:isHover() or self:hasFocus() then
        if self:isHover() then
            self:setCursor(cursors.Hand)
        end

        if (self:isHover() and mouse.is_pressed(buttons.Left)) or keyboard.is_pressed(keys.Space) then
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

---@override
function CheckBox:render()
    if not self:isVisible() then return end

    local color = theme.default

    if not self:isActive() then
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

---@override
---@param state boolean
function CheckBox:setActive(state)
    ---@diagnostic disable-next-line: invisible
    self.is_active = state
    self.label:setActive(state)
    self.mark:setActive(state)
end

---@return boolean
function CheckBox:isChecked()
    return self.is_checked
end

---@param state boolean
function CheckBox:setCheckState(state)
    self.is_checked = state
end

---@return string
function CheckBox:text()
    return self.label:text()
end

---@param title string
function CheckBox:setText(title)
    self.label:setText(title)
    self.mutable_offset = title == "" and 0 or self.offset
end

return CheckBox