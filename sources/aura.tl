--TODO: split aura.tl to modules
--TODO: write docs
require("application")
require("image")
require("label")
require("layout")
require("spacer")
require("widget")
require("window")
require("groupbox")
require("progressbar")
require("pushbutton")
require("checkbox")
require("userinterface")
require("listview")
require("slider")

-- hook:
local deltatime = require("externals/deltatime/deltatime")
local moonshine_display = window.display
_G["window"].display = function()
    process_signals()
    moonshine_display()
    cursor_system.update()
    dt = deltatime.getTime()
end