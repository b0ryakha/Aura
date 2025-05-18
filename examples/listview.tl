package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("ListView")
local layout = app:layout()
layout:setLayoutType("HBox")

local flows = { "TopToBottom", "LeftToRight" }
local sizes = { Vector2:new(200, 350), Vector2:new(350, 200) }

for i = 1, #flows do
    local list_view = ListView:new(sizes[i])
    list_view:setFlow(flows[i])

    local list_model = ListModel:new()
    for j = 1, cmath.rand_int(5, 15) do
        list_model:insert(ModelIndex:new(j), ModelItem:new("Item #" .. j))
    end

    list_view:setModel(list_model)

    connect(list_view.itemSelected, function(data: Data)
        local index = data.index as ModelIndex
        print(format("[%] selected: %, index: %", flows[i], list_model:data(index), index))
    end)

    connect(list_view.itemPressed, function(data: Data)
        local index = data.index as ModelIndex
        print(format("[%] pressed: %, index: %", flows[i], list_model:data(index), index))
    end)

    connect(list_view.itemClicked, function(data: Data)
        local index = data.index as ModelIndex
        print(format("[%] clicked: %, index: %", flows[i], list_model:data(index), index))
    end)

    connect(list_view.itemDoubleClicked, function(data: Data)
        local index = data.index as ModelIndex
        print(format("[%] double clicked: %, index: %", flows[i], list_model:data(index), index))
    end)

    local internal_layout = Layout:new()
    internal_layout:setLayoutType("VBox")
    internal_layout:addItem(Label:new(flows[i]))
    internal_layout:addItem(list_view)
    layout:addItem(internal_layout)
end

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end