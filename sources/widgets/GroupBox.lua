local Widget = require("Widget")
local Signal = require("Signal")
local Label = require("Label")
local CheckBox = require("CheckBox")
local fmt = require("fmt")
local theme = require("theme")

---@class (exact) GroupBox: Widget
---@operator call: GroupBox
---@field private label Label
---@field private checkbox CheckBox
---
---@field private offset integer
---@field private is_flat boolean
---@field private is_checkable boolean
---
---@field checkStateChanged Signal
local GroupBox = {}

---@param title string
---@param size Vector2
---@param parent Widget
---@return GroupBox
function GroupBox:new(title, size, parent)
    local self = extends(GroupBox, "GroupBox", Widget, parent, nil, size)

    self.label = Label(title)
    self.label:bindPos(self.m_pos)

    self.checkbox = CheckBox(title, nil)
    self.checkbox:bindPos(self.m_pos)
    self.checkbox:setCheckState(true)
    connect(self.checkbox.checkStateChanged, function(data)
        ---@diagnostic disable-next-line: invisible
        if not self.m_layout then return end
        ---@diagnostic disable-next-line: invisible
        for _, child in ipairs(self.m_layout.childs) do
            child:setActive(data.state)
        end
    end)

    self.checkStateChanged = self.checkbox.checkStateChanged -- by ref
    self.offset = cmath.round(self.m_pos.y + self.label:measure().y * 1.5)
    self.is_flat = false
    self.is_checkable = false

    return self
end

setmetatable(GroupBox, { __call = GroupBox.new })

---@override
function GroupBox:update()
    if not self:isActive() then return end

    if self.is_checkable then
        self.checkbox:update()
    end

    self.label:update()
    self.m_layout:update()
end

---@override
---@param layout Layout ref
function GroupBox:setLayout(layout)
    if not layout then return end

    self.m_layout = layout
    self.m_layout:bindPos(self.m_pos)
    self.m_layout:bindSize(self.m_size)
    self.m_layout.childs = self.childs

    local margins = self.m_layout:margins()
    margins.top = margins.top + self.offset
    margins.bottom = margins.bottom - self.offset

    self.m_layout:setMargins(margins)
end

---@override
function GroupBox:render()
    if not self:isVisible() then return end

    if not self.is_flat then
        render.rectangle(self.m_pos.x, self.m_pos.y + self.offset, self.m_size.x, self.m_size.y, theme.background2, 1)
        render.outline_rectangle(self.m_pos.x, self.m_pos.y + self.offset, self.m_size.x, self.m_size.y, 1, theme.outline, 1)
    end

    if self.is_checkable then
        self.checkbox:render()
    else
        self.label:render()
    end

    if self.m_layout then
        self.m_layout:render()
    else
        self:childsRender()
    end
end

---@param item Widget
function GroupBox:addItem(item)
    if not item then
        error(fmt("%: Cannot add a nil item", type(self)))
    end

    if self.m_layout then
        self.m_layout:addChild(item)
    else
        self:addChild(item)
    end
end

---@return string
function GroupBox:title()
    return self.label:text()
end

---@param title string
function GroupBox:setTitle(title)
    self.label:setText(title)
    self.checkbox:setText(title)
end

---@return boolean
function GroupBox:isFlat()
    return self.is_flat
end

---@param state boolean
function GroupBox:setFlat(state)
    self.is_flat = state
end

---@return boolean
function GroupBox:isCheckable()
    return self.is_checkable
end

---@param state boolean
function GroupBox:setCheckable(state)
    self.is_checkable = state
end

return GroupBox