local aura = require("aura")

local app = aura.Application("Explorer")
local layout = app:layout()
layout:setSpacing(0)
layout:setMargins(aura.Margins(0, 0, 0, 0))

local header = aura.Layout("HBox", Vector2:new(layout:size().x, 44), layout)
header:setSizePolicy(aura.Policy("Maximum", "Minimum"))
header:turnDebug()

local al = aura.Image("./examples/assets/arrow_left.png", Vector2:new(21, 21), header)
al:setToolTip("prev folder")

local ar = aura.Image("./examples/assets/arrow_left.png", Vector2:new(21, 21), header)
ar:mirror()
ar:setToolTip("next folder")

local ad = aura.Image("./examples/assets/arrow_down.png", Vector2:new(12, 12), header)
ad:setToolTip("menu...")

local au = aura.Image("./examples/assets/arrow_up.png", Vector2:new(21, 21), header)
au:setToolTip("back to folder")

local search = aura.Window(aura.Policy("Maximum"), nil, header)
search:setToolTip("search...")

local page = aura.Layout("HBox", nil, layout)
page:turnDebug()
page:setSpacing(4)

local list = aura.Window(aura.Policy("Minimum", "Maximum"), Vector2:new(200, page:size().y), page)
list:setToolTip("list of folders =)")

local view = aura.Window(aura.Policy("Maximum"), nil, page)
view:setToolTip("folder view =)")

while window.is_open() do
    app:update()

    window.clear()
    app:render()
    window.display()
end