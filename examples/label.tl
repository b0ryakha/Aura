package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Layouts")
app:setLayoutType("HBox")

local left = Layout:new("VBox", nil, app:layout())

local label = Label:new("Evelyn Smith")
label:resize(Vector2:new(150, 150))
label:turnDebug()
label:setAlignment(Align:new("Center", "Bottom"))

local link = Label:new("https://www.youtube.com")
link:makeClickable()

left:addItem(label)
left:addItem(Label:new("designer"))
left:addItem(link)

local right = Layout:new("VBox", nil, app:layout())

local wrapped_label = Label:new("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed dolor risus, tincidunt sed quam sit amet, fermentum commodo justo. Morbi cursus nibh sed dui condimentum blandit. Sed sed ante est.")
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