require("application")
require("icon")
require("label")
require("layout")
require("spacer")
require("widget")
require("window")
require("groupbox")
require("progressbar")

-- hook:
local deltatime = require("externals/deltatime/deltatime")
global dt: number = 0
local moonshine_display = window.display
_G["window"].display = function()
    process_signals()
    moonshine_display()
    dt = deltatime.getTime()
end

-- default signals:
Signal:new("window_resized", function(data: Data): boolean
    if not data.new_size then data.new_size = window.get_size() end

    if data.new_size ~= window.get_size() then
        data.new_size = window.get_size()
        return true
    end

    return false
end)

Signal:new("startup", function(data: Data): boolean
    if not data.started then
        data.started = true
        return true
    end

    return false
end)

Signal:new("cursor_stopped", function(data: Data): boolean
    if not data.old_cursor_pos then data.old_cursor_pos = cursor.get_pos() end
    if not data.duration then data.duration = 0 end

    if data.old_cursor_pos == cursor.get_pos() then
        data.duration = data.duration as number + dt
        return true
    else
        data.duration = 0
        data.old_cursor_pos = cursor.get_pos()
    end

    return false
end)

Signal:new("new_frame", function(_: Data): boolean
    return true
end)