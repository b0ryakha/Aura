local aura = require("aura")

local ui = aura.UserInterface("examples/forms/1.ui")
local app = ui.app as aura.Application

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end