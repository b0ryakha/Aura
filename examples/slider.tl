package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("Slider")
local layout = app:layout()
layout:setLayoutType("HBox")

local left = Layout:new("VBox", nil, layout)
left:setSpacing(100)
local right = Layout:new("HBox", nil, layout)
right:setSpacing(100)

local slider1 = Slider:new(Vector2:new(500, 20), left)
local slider2 = Slider:new(Vector2:new(500, 20), left)
local slider3 = Slider:new(Vector2:new(500, 50), left)

local slider4 = Slider:new(Vector2:new(20, 300), right)
local slider5 = Slider:new(Vector2:new(50, 300), right)
local slider6 = Slider:new(Vector2:new(20, 300), right)

slider2:setInvertedAppearance(true)
slider2:setRange(0, 5)
slider2:setTickPosition("BothSides")
slider3:setOrientation("Vertical")
slider3:setTickPosition("BothSides")
slider3:turnDebug()

slider4:setOrientation("Vertical")
slider4:setTickPosition("Left")
slider5:setInvertedAppearance(true)
slider5:turnDebug()
slider5:setTickPosition("Above")
slider6:setOrientation("Vertical")
slider6:setInvertedAppearance(true)
slider6:setTickPosition("Right")

slider1:setValue(cmath.rand_int(0, 100))
slider2:setValue(cmath.rand_int(0, 100))
slider3:setValue(cmath.rand_int(0, 100))
slider4:setValue(cmath.rand_int(0, 100))
slider5:setValue(cmath.rand_int(0, 100))
slider6:setValue(cmath.rand_int(0, 100))

connect(slider1.valueChanged, function()
    print(format("1: changed to percent: %", slider1:percent()))
end)

connect(slider2.valueChanged, function()
    print(format("3: changed to value: %", slider2:value()))
end)

connect(slider6.valueChanged, function()
    print(format("6: changed to percent: %", slider6:percent()))
end)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end