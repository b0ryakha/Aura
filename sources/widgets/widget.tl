local type IWidget = require("IWidget")
local Signal = require("Signal")
local Policy = require("Policy")
local Geometry = require("Geometry")
local fmt = require("fmt")
local cursors = require("cursors")
local theme = require("theme")
require("oop")

local record Widget is IWidget end

local focused: IWidget = nil

function Widget:new(parent?: IWidget, size_policy?: Policy, size?: Vector2): Widget
    local self = create(Widget, "Widget")

    self.m_pos = Vector2:new(0, 0)
    self.is_visible = true
    self.is_active = true

    self.m_size = size and size:copy() or Vector2:new(100, 100)
    self.min_size = self.m_size:copy()
    self.size_policy = size_policy or Policy:new("Minimum")
    self:resetCursor()

    self.tooltip = ""
    self.tooltip_duration = 0
    self.is_tooltip_visible = false

    self.childs = {}

    if parent then
        self:setParent(parent)
    end

    self.sizeChanged = Signal:new()
    self.posChanged = Signal:new()

    connect(window_resized, function() self:update() end)
    connect(window_started, function() self:update() end)
    connect(cursor_stopped, function(data: SignalData)
        self.tooltip_duration = data.duration as number
    end)
    connect(window_updated, function()
        if not self.is_active then return end
        self:renderToolTip()

        if self:isHover() and mouse.is_pressed(button.Left) then
            self:peekFocus()
        end
    end)

    cursors.add_element(self)

    return self
end

-- virtual:
function Widget:render() self:childsRender() end

-- virtual:
function Widget:update() self:childsUpdate() end

-- virtual:
function Widget:setLayout(layout: IWidget)
    if not layout then return end

    self.m_layout = layout -- by ref
    self.m_layout:setParent(self)
    self.m_layout:bindPos(self.m_pos)
    self.m_layout:bindSize(self.m_size)
end

-- virtual:
function Widget:renderToolTip()
    if self.tooltip == "" then return end

    local is_bound = self:isHover()

    if not self.is_tooltip_visible then
        if self.tooltip_duration > 0.5 and is_bound then
            self.is_tooltip_visible = true
        else
            return
        end
    elseif not is_bound then
        self.is_tooltip_visible = false
    end

    local font = theme.small_font
    local measure = render.measure_text(font as Font, self.tooltip as string)
    local m_pos = cursor.get_pos()
    local cursor_size = 16
    local offset = 4

    render.rectangle(m_pos.x + cursor_size, m_pos.y + cursor_size, measure.x + offset * 2, measure.y + offset * 2, theme.background4, 1)
    render.outline_rectangle(m_pos.x + cursor_size, m_pos.y + cursor_size, measure.x + offset * 2, measure.y + offset * 2, 1, theme.outline2, 1)
    render.text(m_pos.x + cursor_size + offset, m_pos.y + cursor_size + offset, font, self.tooltip, theme.foreground4)
end

-- virtual:
function Widget:minSize(): Vector2
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

-- virtual:
function Widget:bindSize(size: Vector2)
    if not size then
        error(fmt("%: Cannot bind a nil size", type(self)))
    end

    self.m_size = size
    self.min_size = size
    if self.m_layout then self.m_layout:bindSize(size) end
    self:update()

    if self.m_size ~= size then
        emit(self.sizeChanged)
    end
end

-- virtual:
function Widget:bindPos(pos: Vector2)
    if not pos then
        error(fmt("%: Cannot bind a nil pos", type(self)))
    end

    self.m_pos = pos
    self:update()

    if self.m_pos ~= pos then
        emit(self.posChanged)
    end
end

-- virtual:
function Widget:setVisible(visible: boolean)
    self.is_visible = visible
end

-- virtual:
function Widget:setActive(state: boolean)
    self.is_active = state
end

function Widget:__tostring(): string
    return fmt("%(pos: %, size: %, policy: %)", type(self), self.m_pos, self.m_size, self.size_policy)
end

function Widget:childsRender()
    if not self:isVisible() then return end

    for _, child in ipairs(self.childs) do
        child:render()
    end

    if self.m_layout then
        self.m_layout:render()
    end
end

function Widget:childsUpdate()
    if not self:isActive() then return end

    for _, child in ipairs(self.childs) do
        child:update()
    end
end

function Widget:addChild(widget: IWidget)
    if not widget then return end

    widget.m_parent = self
    table.insert(self.childs, widget)
end

function Widget:setParent(widget: IWidget)
    if not widget then return end
    widget:addChild(self)
end

function Widget:isHover(): boolean
    return cursor.is_bound(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y)
end

function Widget:peekFocus()
    focused = self
end

function Widget:hasFocus(): boolean
    return self == focused
end

function Widget:setToolTip(tp: string)
    self.tooltip = tp
end

function Widget:size(): Vector2
    return self.m_size:copy()
end

function Widget:minimize()
    self:bindSize(self:minSize())
end

function Widget:resize(size: Vector2)
    if not size then
        error(fmt("%: Cannot set a nil size", type(self)))
    end

    self:bindSize(size:copy())
end

function Widget:geometry(): Geometry
    return Geometry:new(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y)
end

function Widget:pos(): Vector2
    return self.m_pos:copy()
end

function Widget:setPos(pos: Vector2)
    if not pos then
        error(fmt("%: Cannot set a nil pos", type(self)))
    end

    self:bindPos(pos:copy())
end

function Widget:setGeometry(geometry: Geometry)
    self:bindPos(Vector2:new(geometry.x, geometry.y))
    self:bindSize(Vector2:new(geometry.width, geometry.height))
end

function Widget:childAt(index: integer): IWidget
    local widget = self.childs[index]
    if not widget then
        error(fmt("%: Out of bounds (len: %, i: %)", type(self), #self.childs, index))
    end

    return widget
end

function Widget:cursor(): integer
    return self.cursor_type
end

function Widget:setCursor(new_type: integer)
    self.cursor_type = new_type
end

function Widget:resetCursor()
    self:setCursor(cursor_type.Arrow)
end

function Widget:setSizePolicy(size_policy: Policy)
    if not size_policy then return end
    self.size_policy = size_policy
    self:update()
end

function Widget:sizePolicy(): Policy
    return self.size_policy
end

function Widget:toolTip(): string
    return self.tooltip
end

function Widget:parent(): IWidget
    return self.m_parent
end

function Widget:isVisible(): boolean
    return self.is_visible
end

function Widget:hide()
    self.is_visible = false
end

function Widget:show()
    self.is_visible = true
end

function Widget:isActive(): boolean
    return self.is_active
end

function Widget:disable()
    self:setActive(false)
end

function Widget:enable()
    self:setActive(true)
end

return Widget