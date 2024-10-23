package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("ProgressBar")
local layout = Layout:new(app, "VBox")

Label:new(layout, "Never give up...")
local bar = ProgressBar:new(layout, Policy:new("Minimum"), Vector2:new(500, 50))
local percent: number = 0

while window.is_open() do
    percent = cmath.lerp(percent, math.abs(math.sin(os.time())) * 100, dt)

    app:update()
    bar:setPercent(math.floor(percent))

    window.clear()
    app:render()
    window.display()
end