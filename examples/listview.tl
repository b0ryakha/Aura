package.path = package.path .. ";./build/?.lua"
local aura = require("aura")

local app = aura.Application("ListView")
local layout = app:layout()
layout:setLayoutType("HBox")

local flows = { "TopToBottom", "LeftToRight" }
local sizes = { Vector2:new(200, 350), Vector2:new(350, 200) }

for i = 1, #flows do
    local list_view = aura.ListView(sizes[i])
    list_view:setFlow(flows[i])

    local list_model = aura.ListModel()
    for j = 1, cmath.rand_int(5, 15) do
        list_model:insert(aura.ModelIndex(j), aura.ModelItem("Item #" .. j))
    end

    list_view:setModel(list_model)

    connect(list_view.itemSelected, function(data: SignalData)
        local index = data.index as aura.ModelIndex
        print(aura.fmt("[%] selected: %, index: %", flows[i], list_model:data(index), index))
    end)

    connect(list_view.itemPressed, function(data: SignalData)
        local index = data.index as aura.ModelIndex
        print(aura.fmt("[%] pressed: %, index: %", flows[i], list_model:data(index), index))
    end)

    connect(list_view.itemClicked, function(data: SignalData)
        local index = data.index as aura.ModelIndex
        print(aura.fmt("[%] clicked: %, index: %", flows[i], list_model:data(index), index))
    end)

    connect(list_view.itemDoubleClicked, function(data: SignalData)
        local index = data.index as aura.ModelIndex
        print(aura.fmt("[%] double clicked: %, index: %", flows[i], list_model:data(index), index))
    end)

    local internal_layout = aura.Layout()
    internal_layout:setLayoutType("VBox")
    internal_layout:addItem(aura.Label(flows[i]))
    internal_layout:addItem(list_view)
    layout:addItem(internal_layout)
end

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end