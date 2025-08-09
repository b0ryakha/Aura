local aura = require("aura")

local app = aura.Application("Tooltip")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(100)

local label = aura.Label("Point it at me ->")
label:setToolTip("Not on the text...")

local win = aura.Window(aura.Policy("Minimum"), Vector2:new(250, 250))
win:setToolTip("The square is a quadrangle with pride!")

layout:addItem(label)
layout:addItem(win)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end