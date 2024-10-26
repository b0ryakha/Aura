package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Tooltip")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(100)

local label = Label:new("Point it at me ->")
label:setToolTip("Not on the text...")

local win = Window:new(Policy:new("Minimum"), Vector2:new(250, 250))
win:setToolTip("The square is a quadrangle with pride!")

layout:addItem(label)
layout:addItem(win)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end