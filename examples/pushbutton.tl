package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("PushButton")
local layout = Layout:new(app, "HBox")
layout:setSpacing(200)

local btn1 = PushButton:new(layout, "on click")
connect(btn1.clicked, function() print("Clicked button #1") end)

local btn2 = PushButton:new(layout, "on release", Policy:new("Minimum"), Vector2:new(250, 50))
btn2:setTooltip("...")
connect(btn2.released, function() print("Released button #2") end)

local btn3 = PushButton:new(layout, "on pressed", Policy:new("Minimum"), Vector2:new(250, 50))
connect(btn3.pressed, function() print("Pressed button #3") end)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end