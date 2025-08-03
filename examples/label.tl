package.path = package.path .. ";./build/?.lua"
local aura = require("aura")

local app = aura.Application:new("aura.Label")
app:setLayoutType("HBox")

local left = aura.Layout:new("VBox", nil, app:layout())

local label = aura.Label:new("Evelyn Smith")
label:resize(Vector2:new(150, 150))
label:turnDebug()
label:setAlignment(aura.Align:new("Center", "Bottom"))

local link = aura.Label:new("https://www.youtube.com")
link:makeClickable()

left:addItem(label)
left:addItem(aura.Label:new("designer"))
left:addItem(link)

local right = aura.Layout:new("VBox", nil, app:layout())

local wrapped_label = aura.Label:new("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed dolor risus, tincidunt sed quam sit amet, fermentum commodo justo. Morbi cursus nibh sed dui condimentum blandit.")
wrapped_label:resize(Vector2:new(100, 200))
wrapped_label:setWordWrap(true)
wrapped_label:turnDebug()

right:addItem(wrapped_label)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end