local Widget = require("Widget")
local Align = require("Align")
local Signal = require("Signal")
local Label = require("Label")
local Image = require("Image")
local theme = require("theme")
local fmt = require("fmt")

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
---@field private bindPos fun() blocked
---
---@field checkStateChanged Signal
local CheckBox = {}

---@param text? string
---@param size? Vector2
---@param parent? Widget
---@return CheckBox
function CheckBox:new(text, size, parent)
    local self = extends(self, "CheckBox", Widget, parent, nil, nil)

    self.box_size = size or Vector2:new(14, 14)
    self.offset = 5
    self.mutable_offset = self.offset

    self.label = Label(text, self)
    self.label:setAlignment(Align("Center"))
    self.label.m_size.y = self.box_size.y
    self.label:redirectFocus(self)

    self.state = "Normal"
    self.lock_press = false
    self.is_checked = false

    self.mark = Image("assets/checkmark.png", Vector2:new(64, 64), self)
    self.mark:setVisible(self.is_checked)

    self.checkStateChanged = Signal()

    connect(self.enabled, function()
        ---@diagnostic disable-next-line: invisible
        self.label:setEnabled(self:isEnabled())
        ---@diagnostic disable-next-line: invisible
        self.mark:setEnabled(self:isEnabled())
    end)

    connect(self.disabled, function()
        ---@diagnostic disable-next-line: invisible
        self.label:setEnabled(self:isEnabled())
        ---@diagnostic disable-next-line: invisible
        self.mark:setEnabled(self:isEnabled())
    end)

    connect(self.sizeChanged, function()
        ---@diagnostic disable-next-line: invisible
        self.mark:resize(self.box_size)
    end)

    connect(self.posChanged, function()
        ---@diagnostic disable-next-line: invisible
        self.label:bindPos(Vector2:new(self.m_pos.x + self.box_size.x + self.mutable_offset, self.m_pos.y))
        ---@diagnostic disable-next-line: invisible
        self.mark:setPos(self.m_pos)
    end)

    self:bindSize(Vector2:new(self.box_size.x + self.label.m_size.x + self.mutable_offset, self.box_size.y))

    return self
end

setmetatable(CheckBox, { __call = CheckBox.new })

---@return string
function CheckBox:__tostring()
    return fmt("%(text: %, checked: %)", type(self), self.label:text(), self.is_checked)
end

---@override
function CheckBox:update()
    if not self:isEnabled() or not self:isVisible() then return end

    if self:isHover() or self:hasFocus() then
        if self:isHover() then
            self:setCursor(cursors.Hand)
        end

        if (self:isHover() and mouse.is_pressed(buttons.Left)) or keyboard.is_pressed(keys.Space) then
            self.state = "Pressed"

            if not self.lock_press then
                self.lock_press = true
            end
        elseif self.lock_press then
            self.lock_press = false
            self.state = "Normal"

            self.is_checked = not self.is_checked
            self.mark:setVisible(self.is_checked)

            emit(self.checkStateChanged, { ["state"] = self.is_checked })
        end
    else
        self.state = "Normal"
    end

    self:parentUpdate()
end

---@override
function CheckBox:render()
    if not self:isVisible() then return end

    local bg_color = theme.background2
    local outline_color = theme.outline3

    if not self:isEnabled() then
        bg_color = theme.background1
        outline_color = theme.outline1
    else
        if self:isHover() or self.is_checked then
            outline_color = theme.accent3
        end

        if self:hasFocus() then
            local x = self.m_pos.x + self.box_size.x + self.mutable_offset
            local y = self.m_pos.y + self.box_size.y + 2
            render.rectangle(x, y, self.label:measure().x, 1, theme.accent3)
        end

        if self.state == "Pressed" then
            bg_color = self.is_checked and theme.accent1 or theme.background1
        elseif self.is_checked then
            bg_color = theme.accent2
        end
    end

    render.rectangle(self.m_pos.x, self.m_pos.y, self.box_size.x, self.box_size.y, bg_color, 25)
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.box_size.x, self.box_size.y, 1, outline_color, 25)

    self:parentRender()
end

---@return boolean
function CheckBox:isChecked()
    return self.is_checked
end

---@param state boolean
function CheckBox:setCheckState(state)
    self.is_checked = state
    self.mark:setVisible(state)
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