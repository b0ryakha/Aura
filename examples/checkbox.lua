local aura = require("aura")

local app = aura.Application("CheckBox")
local layout = app:layout()
layout:setSpacing(30)

local check1 = aura.CheckBox("test")
connect(check1.checkStateChanged, function() print("#1") end)

local check2 = aura.CheckBox("#2")
connect(check2.checkStateChanged, function() print("#2") end)

local check3 = aura.CheckBox("disabled :(")
check3:setEnabled(false)

local check4 = aura.CheckBox("Middle click me!")
local lock_click = false
check4:setCheckState(true)
check4:setEnabled(false)

layout:addItem(check1)
layout:addItem(check2)
layout:addItem(check3)
layout:addItem(check4)

while window.is_open() do
    app:update()

    if mouse.is_pressed(buttons.Middle) and check4:isHover() then
        if not lock_click then
            check4:setEnabled(not check4:isEnabled())
            lock_click = true
        end
    else
        lock_click = false
    end

    window.clear()
    app:render()
    window.display()
end