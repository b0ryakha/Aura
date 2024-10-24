require("oop")
require("policy")
require("signal")
require("format")
require("cachedfont")
require("cachedcolor")
require("layouttype")

--global dbg = require("externals/debugger/debugger") as Debugger

global interface IWidget
    m_parent: IWidget
    childs: { IWidget }
    m_layout: IWidget

    m_pos: Vector2
    is_visible: boolean

    m_size: Vector2
    min_size: Vector2
    size_policy: Policy
    cursor_type: integer

    tooltip: string
    tooltip_duration: number
    is_tooltip_visible: boolean

-- public:
    parentWidget: function<Self>(Self): IWidget
    childAt: function<Self>(Self, integer): IWidget
    pos: function<Self>(Self): Vector2
    isVisible: function<Self>(Self): boolean
    size: function<Self>(Self): Vector2
    sizePolicy: function<Self>(Self): Policy
    cursor: function<Self>(Self): integer
    toolTip: function<Self>(Self): string

    setParent: function<Self>(Self, IWidget)
    addChild: function<Self>(Self, IWidget)
    setLayout: function<Self>(Self, IWidget)
    setPos: function<Self>(Self, Vector2)
    bindPos: function<Self>(Self, Vector2)
    setVisible: function<Self>(Self, boolean)
    hide: function<Self>(Self)
    show: function<Self>(Self)
    resize: function<Self>(Self, Vector2)
    bindSize: function<Self>(Self, Vector2)
    setSizePolicy: function<Self>(Self, Policy)
    setCursor: function<Self>(Self, integer)
    resetCursor: function<Self>(Self)
    setToolTip: function<Self>(Self, string)

    isHover: function<Self>(Self): boolean
    render: function<Self>(Self)
    update: function<Self>(Self)
    renderToolTip: function<Self>(Self)
    childsRender: function<Self>(Self)
    childsUpdate: function<Self>(Self)
end

global record Widget is IWidget end

function Widget:new(parent: IWidget, size_policy?: Policy, size?: Vector2): Widget
    local self = create(Widget, "Widget")

    self.m_pos = Vector2:new(0, 0)
    self.is_visible = true

    self.m_size = size and size:copy() or Vector2:new(100, 100)
    self.min_size = self.m_size:copy()
    self.size_policy = size_policy or Policy:new("Minimum")
    self:resetCursor()

    self.tooltip = ""
    self.tooltip_duration = 0
    self.is_tooltip_visible = false

    self.childs = {}
    self:setParent(parent)

    connect(window_resized, function() self:update() end)
    connect(startup, function() self:update() end)
    connect(cursor_stopped, function(data: Data)
        self.tooltip_duration = data.duration as number
    end)
    connect(update, function()
        cursor.change_type(self.cursor_type)
        self:renderToolTip()
    end)
    
    return self
end

function Widget:__tostring(): string
    return format("%(pos: %, size: %, policy: \"%\")", type(self), self.m_pos, self.m_size, self.size_policy)
end

function Widget:childsRender()
    for _, child in ipairs(self.childs) do
        child:render()
    end

    if self.m_layout then
        self.m_layout:render()
    end
end

function Widget:childsUpdate()
    for _, child in ipairs(self.childs) do
        child:update()
    end
end

function Widget:render() self:childsRender() end
function Widget:update() self:childsUpdate() end

function Widget:addChild(widget: IWidget)
    if not widget then return end

    widget.m_parent = self
    table.insert(self.childs, widget)
end

function Widget:setParent(widget: IWidget)
    if not widget then return end
    widget:addChild(self)
end

function Widget:setLayout(layout: IWidget)
    if not layout then return end

    self.m_layout = layout
    self.m_layout:setParent(self)
    self.m_layout:bindPos(self.m_pos)
    self.m_layout:bindSize(self.m_size)
end

function Widget:isHover(): boolean
    return cursor.is_bound(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y)
end

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

    local font = CachedFont:new("SansSerif.ttf", 13)
    local measure = render.measure_text(font as Font, self.tooltip as string)
    local m_pos = cursor.get_pos()
    local cursor_size = 16
    local offset = 4

    render.rectangle(m_pos.x + cursor_size, m_pos.y + cursor_size, measure.x + offset * 2, measure.y + offset * 2, CachedColor:new(255, 255, 255), 1)
    render.outline_rectangle(m_pos.x + cursor_size, m_pos.y + cursor_size, measure.x + offset * 2, measure.y + offset * 2, 1, CachedColor:new(150, 150, 150), 1)
    render.text(m_pos.x + cursor_size + offset, m_pos.y + cursor_size + offset, font, self.tooltip, CachedColor:new(60, 60, 60))
end

function Widget:setToolTip(tp: string)
    self.tooltip = tp
end

function Widget:size(): Vector2
    return self.m_size:copy()
end

function Widget:resize(m_size: Vector2)
    if not m_size then
        error(format("%: Cannot set a nil size", type(self)))
    end

    self.m_size = m_size:copy()
    if self.m_layout then self.m_layout:resize(m_size) end

    self:update()
end

function Widget:bindSize(m_size: Vector2)
    if not m_size then
        error(format("%: Cannot bind a nil size", type(self)))
    end

    self.m_size = m_size
    if self.m_layout then self.m_layout:bindSize(m_size) end

    self:update()
end

function Widget:pos(): Vector2
    return self.m_pos:copy()
end

function Widget:setPos(m_pos: Vector2)
    if not m_pos then
        error(format("%: Cannot set a nil pos", type(self)))
    end

    self.m_pos = m_pos:copy()
    self:update()
end

function Widget:bindPos(m_pos: Vector2)
    if not m_pos then
        error(format("%: Cannot bind a nil pos", type(self)))
    end

    self.m_pos = m_pos
    self:update()
end

function Widget:isVisible(): boolean
    return self.is_visible
end

function Widget:childAt(index: integer): IWidget
    local widget = self.childs[index]
    if not widget then
        error(format("%.at: out of bounds, size: %, but try index: %", type(self), #self.childs, index))
    end

    return widget
end

function Widget:cursor(): integer
    return self.cursor_type
end

function Widget:setCursor(new_type: integer)
    if not new_type then return end
    self.cursor_type = new_type
end

function Widget:resetCursor()
    self.cursor_type = cursor_type.Arrow
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

function Widget:setVisible(visible: boolean)
    self.is_visible = visible
end

function Widget:hide()
    self.is_visible = false
end

function Widget:show()
    self.is_visible = true
end