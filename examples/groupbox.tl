package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Groupbox")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(300)

local group1 = GroupBox:new("Some widgets", Vector2:new(400, 250))
group1:setLayout(Layout:new("VBox"))
group1:addItem(Label:new("Just text"))
group1:addItem(Label:new("hello!"))
group1:addItem(Spacer:new("Vertical"))
group1:addItem(Window:new(Policy:new("Minimum"), Vector2:new(150, 150)))

local group2 = GroupBox:new("Another layout", Vector2:new(300, 200))
group2:setLayout(Layout:new("HBox"))
group2:addItem(Label:new("box ->"))
group2:addItem(Window:new(Policy:new("Minimum"), Vector2:new(50, 50)))

layout:addItem(group1)
layout:addItem(group2)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end