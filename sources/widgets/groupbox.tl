require("label")
require("layout")
require("checkbox")

global record GroupBox is IWidget
    label: Label
    checkbox: CheckBox

    offset: integer

    is_flat: boolean
    is_checkable: boolean

    checkStateChanged: Signal
end

function GroupBox:new(title?: string, size?: Vector2, parent?: IWidget): GroupBox
    local self = extends(GroupBox, "GroupBox", Widget, parent, nil, size)

    self.label = Label:new(title)
    self.label:bindPos(self.m_pos)

    self.checkbox = CheckBox:new(title, nil)
    self.checkbox:bindPos(self.m_pos)
    self.checkbox:setCheckState(true)
    connect(self.checkbox.checkStateChanged, function(data: Data)
        for _, child in ipairs(self.m_layout.childs) do
            child:setActive(data.state as boolean)
        end
    end)

    self.checkStateChanged = self.checkbox.checkStateChanged

    self.offset = cmath.round(self.m_pos.y + self.label.measure.y * 1.5)

    self.is_flat = false
    self.is_checkable = false

    return self
end

-- override:
function GroupBox:update()
    if not self.is_active then return end

    if self.is_checkable then
        self.checkbox:update()
    end

    self.label:update()
    self.m_layout:update()
end

-- override:
function GroupBox:setLayout(widget: IWidget)
    if not widget then return end
    local layout = widget as Layout

    layout:bindPos(self.m_pos)
    layout:bindSize(self.m_size)
    layout.margin.top = layout.margin.top + self.offset
    layout.margin.bottom = layout.margin.bottom - self.offset
    layout.childs = self.childs

    self.m_layout = layout
end

-- override:
function GroupBox:render()
    if not self.is_visible then return end

    render.rectangle(self.m_pos.x, self.m_pos.y + self.offset, self.m_size.x, self.m_size.y, theme.background2, 1)

    if not self.is_flat then
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

function GroupBox:addItem(item: IWidget)
    if not item then
        error("Layout: Cannot add a nil item")
    end

    self:addChild(item)
end

function GroupBox:title(): string
    return self.label:text()
end

function GroupBox:setTitle(title: string)
    self.label:setText(title)
    self.checkbox:setText(title)
end

function GroupBox:isFlat(): boolean
    return self.is_flat
end

function GroupBox:setFlat(state: boolean)
    self.is_flat = state
end

function GroupBox:isCheckable(): boolean
    return self.is_checkable
end

function GroupBox:setCheckable(state: boolean)
    self.is_checkable = state
end