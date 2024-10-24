package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("PushButton")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(200)

local btn1 = PushButton:new("on click", nil, layout)
connect(btn1.clicked, function() print("Clicked button #1") end)

local btn2 = PushButton:new("on release", Vector2:new(250, 50), layout)
btn2:setToolTip("...")
connect(btn2.released, function() print("Released button #2") end)

local btn3 = PushButton:new("on pressed", Vector2:new(250, 50), layout)
connect(btn3.pressed, function() print("Pressed button #3") end)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end