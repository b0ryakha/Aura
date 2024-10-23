package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Layouts")
local layout = Layout:new(app, "VBox")

local label = Label:new(layout, "Evelyn Smith")
label:setSize(Vector2:new(150, 150))
label:turnDebug()
label:setAlign(Align:new("Center", "Bottom"))

Label:new(layout, "designer")

local link = Label:new(layout, "https://www.youtube.com")
link:makeClickable()

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end