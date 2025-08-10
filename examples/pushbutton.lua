local aura = require("aura")

local app = aura.Application("PushButton")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(200)

local btn1 = aura.PushButton("on click")
connect(btn1.clicked, function() print("Clicked button #1") end)

local btn2 = aura.PushButton("on release", Vector2:new(250, 50))
connect(btn2.released, function() print("Released button #2") end)

local btn3 = aura.PushButton("on pressed", Vector2:new(250, 50))
connect(btn3.pressed, function() print("Pressed button #3") end)

local btn4 = aura.PushButton("disabled", Vector2:new(250, 50))
btn4:setEnabled(false)

layout:addItem(btn1)
layout:addItem(btn2)
layout:addItem(btn3)
layout:addItem(btn4)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end