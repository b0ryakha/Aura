package.path = package.path .. ";./build/?.lua"
require("aura")

local app = Application:new("CheckBox")
local layout = app:layout()

local check1 = CheckBox:new("test")
connect(check1.checkStateChanged, function() print("#1") end)

local check2 = CheckBox:new("#2")
connect(check2.checkStateChanged, function() print("#2") end)

layout:addItem(check1)
layout:addItem(check2)

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end