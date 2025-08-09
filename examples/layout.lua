local aura = require("aura")

local app = aura.Application("Layout")
app:setLayoutType("HBox")

local layout = app:layout()
layout:turnDebug()

layout:addItem(aura.Window(aura.Policy("Fixed"), Vector2:new(100, 100)))
layout:addItem(aura.Window(aura.Policy("Minimum"), Vector2:new(250, 250)))

local vlayout = aura.Layout("VBox", nil, layout)
vlayout:turnDebug()

vlayout:addItem(aura.Window(aura.Policy("Maximum")))

local spacer = aura.Spacer("Vertical")
spacer:show()

vlayout:addItem(spacer)
vlayout:addItem(aura.Window(aura.Policy("Minimum"), Vector2:new(100, 100)))

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end