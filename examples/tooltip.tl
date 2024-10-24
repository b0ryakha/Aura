package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Layouts")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(100)

local label = Label:new("Point it at me ->", nil, layout)
label:setToolTip("Not on the text...")

local win = Window:new(Policy:new("Minimum"), Vector2:new(250, 250), layout)
win:setToolTip("The square is a quadrangle with pride!")

while window.is_open() do
    window.clear()
    app:render()
    window.display()
end