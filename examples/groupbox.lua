local aura = require("aura")

local app = aura.Application("Groupbox")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(300)

local group1 = aura.GroupBox("Some widgets", Vector2:new(400, 250))
group1:setLayout(aura.Layout("VBox"))
group1:addItem(aura.Label("Just text"))
group1:addItem(aura.Label("hello!"))
group1:addItem(aura.Spacer("Vertical"))
group1:addItem(aura.Window(aura.Policy("Minimum"), Vector2:new(150, 150)))

local group2 = aura.GroupBox("Another layout", Vector2:new(300, 200))
group2:setCheckable(true)
local layout_g2 = aura.Layout("HBox")
layout_g2:setSpacing(25)
group2:setLayout(layout_g2)
group2:addItem(aura.PushButton("click"))
group2:addItem(aura.CheckBox("check"))
group2:addItem(aura.Window(aura.Policy("Minimum"), Vector2:new(50, 50)))

layout:addItem(group1)
layout:addItem(group2)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end