package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Layouts")
local layout = Layout:new(app, "HBox")
layout:setSpacing(100)

local label = Label:new(layout, "The master box")
label:setTooltip("What's not clear here?")

local win = Window:new(layout, Policy:new("Minimum"), Vector2:new(250, 250))
win:setTooltip("The square is a quadrangle with pride!")

while window.is_open() do
    window.clear()
    app:render()
    window.display()
end