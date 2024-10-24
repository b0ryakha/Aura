package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("PushButton")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(200)

local btn1 = PushButton:new("on click")
connect(btn1.clicked, function() print("Clicked button #1") end)

local btn2 = PushButton:new("on release", Vector2:new(250, 50))
connect(btn2.released, function() print("Released button #2") end)

local btn3 = PushButton:new("on pressed", Vector2:new(250, 50))
connect(btn3.pressed, function() print("Pressed button #3") end)

layout:addItem(btn1)
layout:addItem(btn2)
layout:addItem(btn3)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end