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

-- hook:
local deltatime = require("externals/deltatime/deltatime")
local moonshine_display = window.display
_G["window"].display = function()
    process_signals()
    moonshine_display()
    dt = deltatime.getTime()
end