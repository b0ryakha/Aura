local aura = require("aura")

local app = aura.Application("ProgressBar")
local layout = app:layout()
layout:setLayoutType("HBox")

local left = aura.Layout("VBox", nil, layout)
local right = aura.Layout("HBox", nil, layout)

local bar1 = aura.ProgressBar(Vector2:new(500, 50), left)
local bar2 = aura.ProgressBar(Vector2:new(500, 50), left)
local bar3 = aura.ProgressBar(Vector2:new(50, 300), right)
local bar4 = aura.ProgressBar(Vector2:new(50, 300), right)
--TODO: fix an unnecessary increase in the window size, the total size in Layout may not be calculated correctly.
--local bar5 = ProgressBar(Vector2:new(50, 300), right)

bar1:setFormat("p: %p, v: %v, m: %m")
bar2:setInvertedAppearance(true)
bar3:setOrientation("Vertical")
--bar5:setOrientation("Vertical")
--bar5:setInvertedAppearance(true)

local direction = 1
local percent = 0

while window.is_open() do
    percent = percent + direction
    if percent >= 100 then direction = -1
    elseif percent <= 0 then direction = 1 end

    app:update()
    bar1:setValue(math.floor(percent))
    bar2:setValue(math.floor(percent))
    bar3:setValue(math.floor(percent))
    bar4:setValue(math.floor(percent))
    --bar5:setValue(math.floor(percent))

    window.clear()
    app:render()
    window.display()
end