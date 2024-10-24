package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Layouts")
local layout = app:layout()

local label = Label:new("Evelyn Smith")
label:resize(Vector2:new(150, 150))
label:turnDebug()
label:setAlignment(Align:new("Center", "Bottom"))

local link = Label:new("https://www.youtube.com")
link:makeClickable()

layout:addItem(label)
layout:addItem(Label:new("designer"))
layout:addItem(link)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end