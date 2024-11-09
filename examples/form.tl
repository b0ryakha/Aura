package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Form")

local ui = UserInterface:new("examples/forms/1.ui")
app:setLayout(ui.main_layout as Layout)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end