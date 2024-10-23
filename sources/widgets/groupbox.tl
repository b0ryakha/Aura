require("widget")
require("label")
require("layout")
require("oop")

global record GroupBox is IWidget
    label: Label
    label_offset: integer
    layout: Layout
end

function GroupBox:new(parent: IWidget, size_policy: Policy, title?: string, size?: Vector2): GroupBox
    local self = extends(GroupBox, "GroupBox", Widget, parent, size_policy, size)

    self.label = Label:new(nil, title or "")
    self.label:setPos(self.pos) -- by ref
    self.label_offset = cmath.round(self.pos.y + self.label.measure.y * 1.5)

    self:setLayout(Layout:new(self, "VBox"))

    return self
end

-- override:
function GroupBox:addChild(widget: IWidget)
    if not widget then return end
    if not self.layout then return end

    widget.parent = self.layout
    table.insert(self.layout.childs, widget)
end

-- override:
function GroupBox:setLayout(widget: IWidget)
    if not widget then return end

    self.layout = widget as Layout
    self.layout:setPos(self.pos) -- by ref
    self.layout:setSize(self.size) -- by ref
    self.layout.margin.top = self.layout.margin.top + self.label_offset
    self.layout.margin.bottom = self.layout.margin.bottom - self.label_offset
end

-- override:
function GroupBox:render()
    if not self.is_visible then return end

    render.rectangle(
        self.pos.x,
        self.pos.y + self.label_offset,
        self.size.x,
        self.size.y,
        CachedColor:new(245, 245, 245),
        1
    )

    render.outline_rectangle(
        self.pos.x,
        self.pos.y + self.label_offset,
        self.size.x,
        self.size.y,
        1,
        CachedColor:new(150, 150, 150),
        1
    )

    self.label:render()
    self.layout:render()
end