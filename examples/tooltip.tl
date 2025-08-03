package.path = package.path .. ";./build/?.lua"
local aura = require("aura")

local app = aura.Application:new("Tooltip")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(100)

local label = aura.Label:new("Point it at me ->")
label:setToolTip("Not on the text...")

local win = aura.Window:new(aura.Policy:new("Minimum"), Vector2:new(250, 250))
win:setToolTip("The square is a quadrangle with pride!")

layout:addItem(label)
layout:addItem(win)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end