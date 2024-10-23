require("policy")
require("signal")
require("oop")
require("format")
require("cachedfont")
require("cachedcolor")

global interface IWidget
    parent: IWidget
    childs: { IWidget }

    pos: Vector2
    is_visible: boolean

    size: Vector2
    min_size: Vector2
    size_policy: Policy

    tooltip: string
    tooltip_duration: number
    is_tooltip_visible: boolean

    addChild: function<Self>(Self, IWidget)
    setParent: function<Self>(Self, IWidget)
    setLayout: function<Self>(Self, IWidget)
    renderTooltip: function<Self>(Self)
    setTooltip: function<Self>(Self, string)
    getSize: function<Self>(Self): Vector2
    getPos: function<Self>(Self): Vector2
    hide: function<Self>(Self)
    show: function<Self>(Self)
    isVisible: function<Self>(Self): boolean
    itemsCount: function<Self>(Self): integer
    at: function<Self>(Self, integer): IWidget
    indexOf: function<Self>(Self, IWidget): integer

    -- virtual:
    tostring: function<Self>(Self): string
    setSize: function<Self>(Self, Vector2)
    setPos: function<Self>(Self, Vector2)
    childsRender: function<Self>(Self)
    childsUpdate: function<Self>(Self)
    render: function<Self>(Self)
    update: function<Self>(Self)
end

global record Widget is IWidget end

function Widget:new(parent: IWidget, size_policy: Policy, size: Vector2): Widget
    local self = create(Widget, "Widget")

    self.pos = Vector2:new(0, 0)
    self.is_visible = true

    self.size = size and size:copy() or Vector2:new(100, 100)
    self.min_size = self.size:copy()
    self.size_policy = size_policy or Policy:new("Fixed")

    self.tooltip = ""
    self.tooltip_duration = 0
    self.is_tooltip_visible = false

    self.childs = {}
    self:setParent(parent)

    connect("new_frame", function() self:renderTooltip() end)
    connect("window_resized", function() self:update() end)
    connect("startup", function() self:update() end)
    connect("cursor_stopped", function(data: Data)
        self.tooltip_duration = data.duration as number
    end)
    
    return self
end

function Widget:__tostring(): string
    return format("%(pos: %, size: %, policy: \"%\")", type(self), self.pos, self.size, self.size_policy)
end

function Widget:childsRender()
    for _, child in ipairs(self.childs) do
        child:render()
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

    widget.parent = self
    table.insert(self.childs, widget)
end

function Widget:setParent(widget: IWidget)
    if not widget then return end
    widget:addChild(self)
end

function Widget:setLayout(widget: IWidget)
    if not widget then return end

    widget:setParent(self)
    widget:setSize(self.size) -- by ref
    widget:setPos(self.pos) -- by ref
end

function Widget:renderTooltip()
    if self.tooltip == "" then return end

    local is_bound = cursor.is_bound(self.pos.x as integer, self.pos.y as integer, self.size.x as integer, self.size.y as integer)

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
    local pos = cursor.get_pos()
    local cursor_size = 16
    local offset = 4

    render.rectangle(
        pos.x as integer + cursor_size,
        pos.y as integer + cursor_size,
        measure.x as integer + offset * 2,
        measure.y as integer + offset * 2,
        CachedColor:new(255, 255, 255),
        1
    )

    render.outline_rectangle(
        pos.x as integer + cursor_size,
        pos.y as integer + cursor_size,
        measure.x as integer + offset * 2,
        measure.y as integer + offset * 2,
        1,
        CachedColor:new(150, 150, 150),
        1
    )

    render.text(
        pos.x as integer + cursor_size + offset,
        pos.y as integer + cursor_size + offset,
        font,
        self.tooltip,
        CachedColor:new(60, 60, 60)
    )
end

function Widget:setTooltip(tp: string)
    self.tooltip = tp
end

function Widget:getSize(): Vector2
    return self.size:copy()
end

function Widget:setSize(size: Vector2)
    if not size then
        error(format("%: Cannot set a nil size", type(self)))
    end

    self.size = size
    self:update()
end

function Widget:getPos(): Vector2
    return self.pos:copy()
end

function Widget:setPos(pos: Vector2)
    if not pos then
        error(format("%: Cannot set a nil pos", type(self)))
    end

    self.pos = pos
    self:update()
end

function Widget:hide()
    self.is_visible = false
end

function Widget:show()
    self.is_visible = true
end

function Widget:isVisible(): boolean
    return self.is_visible
end

function Widget:itemsCount(): integer
    return #self.childs
end

function Widget:at(index: integer): IWidget
    local widget = self.childs[index]
    if not widget then
        error(format("%.at: out of bounds, size: %, but try index: %", type(self), #self.childs, index))
    end

    return widget
end

function Widget:indexOf(widget: IWidget): integer
    if not widget then return -1 end

    for i, child in ipairs(self.childs) do
        if child == widget then return i end
    end

    return -1
end