package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Layouts")
local layout = app:layout()

local label = Label:new("Evelyn Smith", nil, layout)
label:resize(Vector2:new(150, 150))
label:turnDebug()
label:setAlignment(Align:new("Center", "Bottom"))

Label:new("designer", nil, layout)

local link = Label:new("https://www.youtube.com", nil, layout)
link:makeClickable()

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end