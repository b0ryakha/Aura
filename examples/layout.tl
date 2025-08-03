package.path = package.path .. ";./build/?.lua"
local aura = require("aura")

local app = aura.Application:new("Layouts")
app:setLayoutType("HBox")

local layout = app:layout()
layout:turnDebug()

layout:addItem(aura.Window:new(aura.Policy:new("Fixed"), Vector2:new(100, 100)))
layout:addItem(aura.Window:new(aura.Policy:new("Minimum"), Vector2:new(250, 250)))

local vlayout = aura.Layout:new("VBox", nil, layout)
vlayout:turnDebug()

vlayout:addItem(aura.Window:new(aura.Policy:new("Maximum")))

local spacer = aura.Spacer:new("Vertical")
spacer:show()

vlayout:addItem(spacer)
vlayout:addItem(aura.Window:new(aura.Policy:new("Minimum"), Vector2:new(100, 100)))

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end