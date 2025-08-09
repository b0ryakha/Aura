local Widget = require("Widget")
local Delegate = require("Delegate")
local Signal = require("Signal")
local Align = require("Align")
local ModelIndex = require("ModelIndex")
local Geometry = require("Geometry")
local DelegateOption = require("DelegateOption")
local theme = require("theme")
local fmt = require("fmt")

---@alias ListView.Flow "TopToBottom" | "LeftToRight"

---@class (exact) ListView: Widget
---@operator call: ListView
---@field private m_model ListModel
---@field private delegate Delegate
---
---@field private selected ModelIndex
---@field private hovered ModelIndex
---@field private is_pressed boolean
---@field private m_flow ListView.Flow
---@field private m_align Align
---TODO: @field private is_wrap boolean
---TODO: @field private scroll_bar ScrollBar
---
---@field private font Font
---@field private prev_size Vector2
---@field private m_spacing integer
---
---@field private last_click_time number
---@field private double_click_threshold number
---
---@field itemSelected Signal
---@field itemPressed Signal
---@field itemClicked Signal
---@field itemDoubleClicked Signal
local ListView = {}

---@param size Vector2
---@param flow ListView.Flow
---@param parent? Widget
---@return ListView
function ListView:new(size, flow, parent)
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

setmetatable(ListView, { __call = ListView.new })

---@private
---@param index ModelIndex
---@return Geometry 
function ListView:findGeometryFor(index)
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

---@private
---@param geometry Geometry
---@return boolean
function ListView:isInside(geometry)
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

---@param index ModelIndex
function ListView:selectIndex(index)
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

---@private
---@param geometry Geometry
---@param index ModelIndex
function ListView:updateFor(geometry, index)
    if cursor.is_bound(geometry:unpack()) then
        if mouse.is_pressed(buttons.Left) then
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

---@override
function ListView:render()
    if not self:isVisible() then return end

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
                self.m_model:data(index),
                geometry,
                self.font,
                self.m_spacing,
                self.m_align
            ), index)
        end
    end
end

---@return ListModel
function ListView:model()
    return self.m_model
end

---@param model ListModel ref
function ListView:setModel(model)
    if model == nil then
        error(fmt("%: Cannot set a nil model", type(self)))
    end

    self.m_model = model

    connect(self.m_model.dataChanged, function()
        self.delegate:clearCache()
    end)
end

---@param delegate Delegate ref
function ListView:setDelegate(delegate)
    if delegate == nil then
        error(fmt("%: Cannot set a nil delegate", type(self)))
    end

    self.delegate = delegate
end

---@return ModelIndex
function ListView:selectedIndex()
    return self.selected
end

---@return ModelIndex
function ListView:hoveredIndex()
    return self.hovered
end

function ListView:unselectIndex()
    self.selected = ModelIndex()
end

---@param flow ListView.Flow
function ListView:setFlow(flow)
    self.m_flow = flow
end

---@return ListView.Flow
function ListView:flow()
    return self.m_flow
end

---@return Align
function ListView:alignment()
    return self.m_align
end

---@param align Align
function ListView:setAlignment(align)
    self.m_align = align
end

---@return integer
function ListView:spacing()
    return self.m_spacing
end

---@param spacing integer
function ListView:setSpacing(spacing)
    self.m_spacing = spacing
end

return ListView