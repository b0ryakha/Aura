local Widget = require("Widget")
local Label = require("Label")
local CheckBox = require("CheckBox")
local fmt = require("fmt")
local theme = require("theme")
---@TODO: fix the damage when narrowing horizontally

---@class (exact) GroupBox: Widget
---@operator call: GroupBox
---@field private label Label
---@field private checkbox CheckBox
---
---@field private offset integer
---@field private is_flat boolean
---
---@field checkStateChanged Signal
local GroupBox = {}

---@param title string
---@param size Vector2
---@param parent Widget
---@return GroupBox
function GroupBox:new(title, size, parent)
    local self = extends(GroupBox, "GroupBox", Widget, parent, nil, size)

    self.label = Label(title, self)
    self.label:bindPos(self.m_pos)

    self.checkbox = CheckBox(title, nil, self)
    self.checkbox:setCheckState(true)
    self.checkbox:setVisible(false)
    
    self:preventFocus()

    connect(self.posChanged, function()
        ---@diagnostic disable-next-line: invisible
        self.checkbox:setPos(self.m_pos)
    end)

    self.checkStateChanged = self.checkbox.checkStateChanged -- by ref
    connect(self.checkStateChanged, function(data)
        ---@diagnostic disable-next-line: invisible
        if not self.m_layout then return end
        ---@diagnostic disable-next-line: invisible
        for _, item in ipairs(self.m_layout:items()) do
            item:setEnabled(data.state)
        end
    end)

    self.is_flat = false
    self:updateOffset()

    return self
end

setmetatable(GroupBox, { __call = GroupBox.new })

---@return string
function GroupBox:__tostring()
    return fmt("%(t: %, flat: %)", type(self), self.label:text(), self.is_flat)
end

---@override
---@param layout Layout ref
function GroupBox:setLayout(layout)
    if not layout then return end

    self.m_layout = layout
    self.m_layout:bindPos(self.m_pos)
    self.m_layout:bindSize(self.m_size)

    local margins = self.m_layout:margins()
    margins.top = margins.top + self.offset
    margins.bottom = margins.bottom - self.offset

    self.m_layout:setMargins(margins)
end

---@override
function GroupBox:render()
    if not self:isVisible() then return end

    render.rectangle(self.m_pos.x, self.m_pos.y + self.offset, self.m_size.x, self.m_size.y, theme.background2, 1)

    if not self.is_flat then
        local outline_color = self:isEnabled() and theme.outline3 or theme.outline1
        render.outline_rectangle(self.m_pos.x, self.m_pos.y + self.offset, self.m_size.x, self.m_size.y, 1, outline_color, 1)
    end

    self:parentRender()
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
    return self.checkbox:isEnabled()
end

---@param state boolean
function GroupBox:setCheckable(state)
    self.checkbox:setVisible(state)
    self.label:setVisible(not state)
    self:updateOffset()
end

---@private
function GroupBox:updateOffset()
    self.offset = cmath.round(self.m_pos.y + (self:isCheckable() and self.checkbox:size() or self.label:measure()).y * 1.5)
end

return GroupBox