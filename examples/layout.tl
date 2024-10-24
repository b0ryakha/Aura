package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Layouts")
app:setLayoutType("HBox")

local layout = app:layout()
layout:turnDebug()

layout:addItem(Window:new(Policy:new("Fixed"), Vector2:new(100, 100)))
layout:addItem(Window:new(Policy:new("Minimum"), Vector2:new(250, 250)))

local vlayout = Layout:new("VBox", nil, layout)
vlayout:turnDebug()

vlayout:addItem(Window:new(Policy:new("Maximum")))

local spacer = Spacer:new("Vertical")
spacer:show()

vlayout:addItem(spacer)
vlayout:addItem(Window:new(Policy:new("Minimum"), Vector2:new(100, 100)))

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end