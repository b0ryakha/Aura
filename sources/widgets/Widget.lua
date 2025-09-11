local Geometry = require("Geometry")
local Policy = require("Policy")
local Signal = require("Signal")
local fmt = require("fmt")
local cursor_system = require("cursor_system")
require("oop")
---@TODO: add bind system

---@class (exact) Widget
---@operator call: Widget
---@field protected m_parent Widget
---@field protected childs table<integer, Widget>
---@field protected m_layout Layout
---
---@field protected m_pos Vector2
---@field private is_visible boolean
---@field private is_enabled boolean
---
---@field protected m_size Vector2
---@field protected min_size Vector2
---@field protected size_policy Policy
---@field private cursor_type cursors
---
---@field private tooltip ToolTip | nil
---@field private is_prevent_focus boolean
---@field private redirected_widget Widget | nil
---
---@field sizeChanged Signal provides: new_size: Vector2
---@field posChanged Signal provides: new_pos: Vector2
---@field enabled Signal
---@field disabled Signal
local Widget = {}

---@type Widget | nil
local focused = nil

---@param parent? Widget
---@param size_policy? Policy
---@param size? Vector2
---@return Widget
function Widget:new(parent, size_policy, size)
    local self = create(Widget, "Widget")

    self.m_pos = Vector2:new(0, 0)
    self.is_visible = true
    self.is_enabled = true

    self.m_size = size and size:copy() or Vector2:new(100, 100)
    self.min_size = self.m_size:copy()
    self.size_policy = size_policy or Policy("Minimum")
    self:resetCursor()

    self.is_prevent_focus = false
    self.childs = {}

    if parent then
        self:setParent(parent)
    end

    self.sizeChanged = Signal()
    self.posChanged = Signal()
    self.enabled = Signal()
    self.disabled = Signal()

    connect(window_resized, function() self:update() end)
    connect(window_started, function() self:update() end)
    connect(window_updated, function()
        if not self:isEnabled() or not self:isVisible() then return end

        ---@diagnostic disable-next-line: invisible
        if self.tooltip then self.tooltip:update(self:isHover()) end

        if self:isHover() then
            if (mouse.is_pressed(buttons.Left) or
                mouse.is_pressed(buttons.Right) or
                mouse.is_pressed(buttons.Middle) or
                mouse.is_pressed(buttons.XButton1) or
                mouse.is_pressed(buttons.XButton2))
            then
                self:peekFocus()
            end
        end
    end)

    cursor_system.add(self)

    return self
end

setmetatable(Widget, { __call = Widget.new })

---@virtual
function Widget:render() self:widgetRender() end

---@virtual
function Widget:update() self:widgetUpdate() end

---@virtual
---@param layout Layout ref
function Widget:setLayout(layout)
    if not layout then return end

    self.m_layout = layout
    self.m_layout:setParent(self)
    self.m_layout:bindPos(self.m_pos)
    self.m_layout:bindSize(self.m_size)
end

---@virtual
---@return Vector2
function Widget:minSize()
    if self.m_layout then
        return self.m_layout:minSize()
    end

    if #self.childs > 0 then
        local max = Vector2:new(0, 0)

        for _, child in ipairs(self.childs) do
            local min = child:minSize()
            max.x = math.max(max.x, min.x)
            max.y = math.max(max.y, min.y)
        end

        return max
    end

    return self.min_size:copy()
end

---@param size Vector2 ref
function Widget:bindSize(size)
    if not size then
        error(fmt("%: Cannot bind a nil size", type(self)))
    end

    if self.m_size == size then return end

    self.m_size = size
    self.min_size = size
    if self.m_layout then self.m_layout:bindSize(size) end
    self:update()

    emit(self.sizeChanged, { ["new_size"] = size })
end

---@param pos Vector2 ref
function Widget:bindPos(pos)
    if not pos then
        error(fmt("%: Cannot bind a nil pos", type(self)))
    end

    if self.m_pos == pos then return end

    self.m_pos = pos
    self:update()

    emit(self.posChanged, { ["new_pos"] = pos })
end

---@virtual
---@param visible boolean
function Widget:setVisible(visible)
    self.is_visible = visible
end

---@virtual
---@param state boolean
function Widget:setEnabled(state)
    if self.is_enabled == state then return end

    self.is_enabled = state

    if state then emit(self.enabled)
    else emit(self.disabled) end
end

---@return string
function Widget:__tostring()
    return fmt("%(pos: %, size: %, policy: %)", type(self), self.m_pos, self.m_size, self.size_policy)
end

function Widget:widgetRender()
    if not self:isVisible() then return end

    for _, child in ipairs(self.childs) do
        child:render()
    end

    if self.m_layout then
        self.m_layout:render()
    end

    if self.tooltip then
        self.tooltip:render()
    end
end

function Widget:widgetUpdate()
    if not self:isEnabled() or not self:isVisible() then return end

    if self.m_layout then
        self.m_layout:update()
    end

    for _, child in ipairs(self.childs) do
        child:update()
    end
end

---@param child Widget
function Widget:addChild(child)
    if not child then return end

    child.m_parent = self
    table.insert(self.childs, child)
end

---@param parent Widget
function Widget:setParent(parent)
    if not parent then return end
    parent:addChild(self)
end

---@return boolean
function Widget:isHover()
    return cursor.is_bound(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y)
end

---@param is_prevent? boolean
function Widget:preventFocus(is_prevent)
    self.is_prevent_focus = is_prevent or true
end

---@param widget Widget | nil ref
function Widget:redirectFocus(widget)
    if widget == self then
        self.redirected_widget = nil
    end

    self.redirected_widget = widget
end

function Widget:peekFocus()
    if self.redirected_widget then
        if focused ~= self.redirected_widget then
            focused = self.redirected_widget
        end
    else
        if not self.is_prevent_focus then
            if focused ~= self then
                focused = self
            end
        end
    end
end

---@return boolean
function Widget:hasFocus()
    return self == focused
end

---@param tooltip string
function Widget:setToolTip(tooltip)
    if not tooltip or tooltip == "" then
        self.tooltip = nil
    end

    self.tooltip = require("ToolTip"):new(tooltip)
end

---@return Vector2
function Widget:size()
    return self.m_size:copy()
end

function Widget:minimize()
    self:bindSize(self:minSize())
end

---@param size Vector2
function Widget:resize(size)
    if not size then
        error(fmt("%: Cannot set a nil size", type(self)))
    end

    self:bindSize(size:copy())
end

---@return Geometry
function Widget:geometry()
    return Geometry(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y)
end

---@return Vector2
function Widget:pos()
    return self.m_pos:copy()
end

---@param pos Vector2
function Widget:setPos(pos)
    if not pos then
        error(fmt("%: Cannot set a nil pos", type(self)))
    end

    self:bindPos(pos:copy())
end

---@param geometry Geometry
function Widget:setGeometry(geometry)
    self:bindPos(Vector2:new(geometry.x, geometry.y))
    self:bindSize(Vector2:new(geometry.width, geometry.height))
end

---@param index integer
---@return Widget
function Widget:childAt(index)
    local widget = self.childs[index]
    if not widget then
        error(fmt("%: Out of bounds (len: %, i: %)", type(self), #self.childs, index))
    end

    return widget
end

---@return cursors
function Widget:cursor()
    return self.cursor_type
end

---@param new_type cursors
function Widget:setCursor(new_type)
    self.cursor_type = new_type
end

function Widget:resetCursor()
    self:setCursor(cursors.Arrow)
end

---@param size_policy Policy
function Widget:setSizePolicy(size_policy)
    if not size_policy then return end
    self.size_policy = size_policy
    self:update()
end

---@return Policy
function Widget:sizePolicy()
    return self.size_policy
end

---@return string
function Widget:toolTip()
    return self.tooltip and self.tooltip:text() or ""
end

---@return Widget
function Widget:parent()
    return self.m_parent
end

---@return boolean
function Widget:isVisible()
    return self.is_visible
end

function Widget:hide()
    self.is_visible = false
end

function Widget:show()
    self.is_visible = true
end

---@return boolean
function Widget:isEnabled()
    return self.is_enabled
end

function Widget:disable()
    self:setEnabled(false)
end

function Widget:enable()
    self:setEnabled(true)
end

return Widget