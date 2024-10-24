package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Groupbox")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(300)

local group = GroupBox:new("Some widgets", Vector2:new(400, 250))
group:setLayout(Layout:new("VBox"))
layout:addItem(group)

Label:new("Just text", nil, group)
Label:new("hello!", nil, group)
Spacer:new("Vertical", group)
Window:new(Policy:new("Minimum"), Vector2:new(150, 150), group)

local group2 = GroupBox:new("Another layout", Vector2:new(300, 200), layout)
group2:setLayout(Layout:new("HBox"))
Label:new("box ->", nil, group2)
Window:new(Policy:new("Minimum"), Vector2:new(50, 50), group)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end