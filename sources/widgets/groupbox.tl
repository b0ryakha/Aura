require("label")
require("layout")

global record GroupBox is IWidget
    label: Label
    label_offset: integer
    is_flat: boolean
    --TODO: is_checked
end

function GroupBox:new(title: string, size?: Vector2, parent?: IWidget): GroupBox
    local self = extends(GroupBox, "GroupBox", Widget, parent, nil, size)

    self.label = Label:new(title)
    self.label:bindPos(self.m_pos)
    self.label_offset = cmath.round(self.m_pos.y + self.label.measure.y * 1.5)
    self.is_flat = false

    return self
end

-- override:
function GroupBox:setLayout(widget: IWidget)
    if not widget then return end
    local layout = widget as Layout

    layout:bindPos(self.m_pos)
    layout:bindSize(self.m_size)
    layout.margin.top = layout.margin.top + self.label_offset
    layout.margin.bottom = layout.margin.bottom - self.label_offset
    layout.childs = self.childs

    self.m_layout = layout
end

-- override:
function GroupBox:render()
    if not self.is_visible then return end

    render.rectangle(
        self.m_pos.x,
        self.m_pos.y + self.label_offset,
        self.m_size.x,
        self.m_size.y,
        CachedColor:new(245, 245, 245),
        1
    )

    if not self.is_flat then
        render.outline_rectangle(
            self.m_pos.x,
            self.m_pos.y + self.label_offset,
            self.m_size.x,
            self.m_size.y,
            1,
            CachedColor:new(150, 150, 150),
            1
        )
    end

    self.label:render()

    if self.m_layout then
        self.m_layout:render()
    else
        self:childsRender()
    end
end

function GroupBox:title(): string
    return self.label:text()
end

function GroupBox:setTitle(title: string)
    self.label:setText(title)
end

function GroupBox:isFlat(): boolean
    return self.is_flat
end

function GroupBox:setFlat(state: boolean)
    self.is_flat = state
end