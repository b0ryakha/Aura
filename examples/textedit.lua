local aura = require("aura")

local app = aura.Application("TextEdit & LineEdit")
app:setLayoutType("HBox")

local layout = app:layout()
layout:setSpacing(200)

local text_edit = aura.TextEdit("Text...", Vector2:new(200, 150))

local line_edit = aura.LineEdit("why :(", Vector2:new(200, 150))
line_edit:setText("Don't erase me!")

local disabled_line_edit = aura.LineEdit("...", Vector2:new(200, 150))
disabled_line_edit:setEnabled(false)

layout:addItem(text_edit)
layout:addItem(line_edit)
layout:addItem(disabled_line_edit)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end