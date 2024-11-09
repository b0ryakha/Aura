package.path = package.path .. ";./build/?.lua"
require("aura")

local ui = UserInterface:new("examples/forms/1.ui")
local app = ui.app as Application

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end