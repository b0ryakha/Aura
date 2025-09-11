local dt = require("externals/deltatime/deltatime")
require("oop")

---@alias SignalData table<string, any>
---@alias Slot fun(data: SignalData)
---@alias Trigger fun(data: SignalData): boolean

---@class (exact) Signal
---@operator call: Signal
---@field private trigger Trigger
---@field private slots table<integer, Slot>
---
---@field private data SignalData
local Signal = {}

---@type table<integer, Signal>
local signals = {};

---@param trigger? Trigger
---@return Signal
function Signal:new(trigger)
    local self = create(Signal, "Signal")
    
    self.trigger = trigger or function(data) end
    self.slots = {}
    self.data = {}
    
    table.insert(signals, self)
    return signals[#signals]
end

setmetatable(Signal, { __call = Signal.new })

---@private
function Signal:runSlots()
    for _, slot in ipairs(self.slots) do
        slot(self.data)
    end
end

function Signal:process()
    if self.trigger(self.data) then
        self:runSlots()
    end
end

---@param slot Slot
function Signal:addSlot(slot)
    table.insert(self.slots, slot)
end

-- hook:
local original = window.display
---@diagnostic disable-next-line: duplicate-set-field
_G.window.display = function()
    emit(window_updated)

    for _, signal in ipairs(signals) do
        signal:process()
    end

    original()
end

---@param signal Signal
---@param slot Slot
---@diagnostic disable-next-line: lowercase-global
function connect(signal, slot)
    if not signal then
        error("Signal: Cannot connect a slot to nil signal!")
    end

    if not slot then
        error("Signal: Cannot connect a nil slot!")
    end

    signal:addSlot(slot)
end

---@param signal Signal
---@param updated_data? table<string, any>
---@diagnostic disable-next-line: lowercase-global
function emit(signal, updated_data)
    if not signal then
        error("Signal: Cannot emit a nil signal!")
    end

    if updated_data then
        for k, v in pairs(updated_data) do
            ---@diagnostic disable-next-line: invisible
            signal.data[k] = v
        end
    end

---@diagnostic disable-next-line: invisible
    signal:runSlots()
end

-- default signals:

---provides: new_size: Vector2
---@diagnostic disable-next-line: lowercase-global
window_resized = Signal(function(data)
    if not data.new_size then data.new_size = window.get_size() end

    if data.new_size ~= window.get_size() then
        data.new_size = window.get_size()
        return true
    end

    return false
end)

---provides: started: boolean
---@diagnostic disable-next-line: lowercase-global
window_started = Signal(function(data)
    if not data.started then
        data.started = true
        return true
    end

    return false
end)

---provides: duration: number
---@diagnostic disable-next-line: lowercase-global
cursor_stopped = Signal(function(data)
    if not data.old_cursor_pos then data.old_cursor_pos = cursor.get_pos() end
    if not data.duration then data.duration = 0 end

    if data.old_cursor_pos == cursor.get_pos() then
        data.duration = data.duration + dt.getTime()
        return true
    else
        data.duration = 0
        data.old_cursor_pos = cursor.get_pos()
    end

    return false
end)

---@diagnostic disable-next-line: lowercase-global
window_updated = Signal()

return Signal