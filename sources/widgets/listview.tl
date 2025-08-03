local type IDelegate = require("IDelegate")
local type IWidget = require("IWidget")
local Widget = require("Widget")
local Delegate = require("Delegate")
local Signal = require("Signal")
local Align = require("Align")
local ModelIndex = require("ModelIndex")
local ListModel = require("ListModel")
local Geometry = require("Geometry")
local DelegateOption = require("DelegateOption")
local theme = require("theme")
local fmt = require("fmt")

local record ListView is IWidget
    enum Flow
        "TopToBottom" "LeftToRight"
    end

    m_model: ListModel
    delegate: IDelegate

    selected: ModelIndex
    hovered: ModelIndex
    is_pressed: boolean
    m_flow: Flow
    m_align: Align
    --TODO: is_wrap: boolean
    --TODO: scroll_bar

    font: Font
    prev_size: Vector2
    m_spacing: integer

    last_click_time: number
    double_click_threshold: number

-- public:
    itemSelected: Signal
    itemPressed: Signal
    itemClicked: Signal
    itemDoubleClicked: Signal

-- force decl:
    metamethod __call: function<Self>(Self, size?: Vector2, flow?: ListView.Flow, parent?: IWidget): ListView
end

function ListView:new(size?: Vector2, flow?: ListView.Flow, parent?: IWidget): ListView
    local self = extends(ListView, "ListView", Widget, parent, nil, nil)

    self:bindSize(size or Vector2:new(250, 200))

    self.delegate = Delegate()

    self.selected = ModelIndex()
    self.hovered = ModelIndex()
    self.is_pressed = false
    self.m_flow = flow or "TopToBottom"
    self.m_align = Align("Left", "Center")

    self.font = theme.regular_font
    self.m_spacing = math.floor(self.font:get_glyph('@').x * 0.3)

    self.last_click_time = 0
    self.double_click_threshold = 0.25

    self.itemSelected = Signal()
    self.itemPressed = Signal()
    self.itemClicked = Signal()
    self.itemDoubleClicked = Signal()

    return self
end

-- private:
function ListView:findGeometryFor(index: ModelIndex): Geometry
    if index:row() == 1 then
        self.prev_size = Vector2:new(0, 0)
    end

    local pos = self:pos()
    local size = render.measure_text(self.font, tostring(self.m_model:data(index))) + self.m_spacing * 2

    if self.m_flow == "TopToBottom" then
        pos.y = pos.y + self.prev_size.y
        size.x = self:size().x
        size.y = size.y + self.m_spacing
    end

    if self.m_flow == "LeftToRight" then
        pos.x = pos.x + self.prev_size.x
        size.x = size.x + self.m_spacing
        size.y = self:size().y
    end

    self.prev_size = self.prev_size + size:copy()

    return Geometry(pos.x, pos.y, size.x, size.y)
end

-- private:
function ListView:isInside(geometry: Geometry): boolean
    local self_pos = self:pos()
    local self_size = self:size()
    local label_pos = geometry:pos()
    local label_size = geometry:size()

    local self_left = self_pos.x
    local self_top = self_pos.y
    local self_right = self_pos.x + self_size.x
    local self_bottom = self_pos.y + self_size.y

    local label_left = label_pos.x
    local label_top = label_pos.y
    local label_right = label_pos.x + label_size.x
    local label_bottom = label_pos.y + label_size.y

    return (
        math.floor(label_left) >= math.floor(self_left) and
        math.floor(label_top) >= math.floor(self_top) and
        math.floor(label_right) <= math.floor(self_right) and
        math.floor(label_bottom) <= math.floor(self_bottom)
    )
end

function ListView:selectIndex(index: ModelIndex)
    if not index:isValid() then
        error(fmt("%: Cannot select a invalid index", type(self)))
    end

    if self.selected == index then
        return
    end

    self.selected = index
    self.hovered = ModelIndex()

    self.itemSelected:updateData("index", self.selected)
    emit(self.itemSelected)
end

-- private:
function ListView:updateFor(geometry: Geometry, index: ModelIndex)
    if cursor.is_bound(geometry:unpack()) then
        if mouse.is_pressed(button.Left) then
            self.itemPressed:updateData("index", index)
            emit(self.itemPressed)

            local current_time = os.clock()

            if not self.is_pressed then
                self.is_pressed = true

                if (current_time - self.last_click_time) <= self.double_click_threshold then
                    self.itemDoubleClicked:updateData("index", index)
                    emit(self.itemDoubleClicked)
                else
                    self:selectIndex(index)

                    self.itemClicked:updateData("index", index)
                    emit(self.itemClicked)
                end

                self.last_click_time = current_time
            end
        elseif self.is_pressed then
            self.is_pressed = false
        end
        
        if self.selected ~= index then
            self.hovered = index
        end
    else
        self.hovered = ModelIndex()
    end
end

-- override:
function ListView:render()
    if not self.is_visible then return end

    render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, theme.default)
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, theme.outline)

    if self.m_model ~= nil then
        for i = 1, self.m_model:rowCount() do
            local index = ModelIndex(i)

            local geometry = self:findGeometryFor(index)
            if not self:isInside(geometry) then break end

            self:updateFor(geometry, index)

            self.delegate:paint(DelegateOption(
                self.selected == index,
                self.hovered == index,
                self.m_model:data(index) as string,
                geometry,
                self.font,
                self.m_spacing,
                self.m_align
            ), index)
        end
    end
end

function ListView:model(): ListModel
    return self.m_model
end

function ListView:setModel(model: ListModel)
    if model == nil then
        error(fmt("%: Cannot set a nil model", type(self)))
    end

    self.m_model = model -- by ref

    connect(self.m_model.dataChanged, function()
        self.delegate:clear_cache()
    end)
end

function ListView:setDelegate(delegate: IDelegate)
    if delegate == nil then
        error(fmt("%: Cannot set a nil delegate", type(self)))
    end

    self.delegate = delegate -- by ref
end

function ListView:selectedIndex(): ModelIndex
    return self.selected
end

function ListView:hoveredIndex(): ModelIndex
    return self.hovered
end

function ListView:unselectIndex()
    self.selected = ModelIndex()
end

function ListView:setFlow(flow: ListView.Flow)
    self.m_flow = flow
end

function ListView:flow(): ListView.Flow
    return self.m_flow
end

function ListView:alignment(): Align
    return self.m_align
end

function ListView:setAlignment(align: Align)
    self.m_align = align
end

function ListView:spacing(): integer
    return self.m_spacing
end

function ListView:setSpacing(spacing: integer)
    self.m_spacing = spacing
end

return ListView