require("oop")

global type Data = { string : any }
global type Slot = function(Data)
global type Trigger = function(data: Data): boolean

global record Signal
    trigger: Trigger
    slots: { Slot }
    data: Data
end

local signals: { Signal } = {};

function Signal:new(trigger?: Trigger): Signal
    local self = create(Signal, "Signal")
    
    self.trigger = trigger
    self.slots = {}
    self.data = {}
    
    table.insert(signals, self)
    return signals[#signals]
end

-- private:
function Signal:runSlots()
    for _, slot in ipairs(self.slots) do
        slot(self.data)
    end
end

function Signal:process()
    if self.trigger and self.trigger(self.data) then
        self:runSlots()
    end
end

function Signal:addSlot(slot: Slot)
    table.insert(self.slots, slot)
end

global function process_signals()
    for _, signal in ipairs(signals) do
        signal:process()
    end
end

global function connect(signal: Signal, slot: Slot)
    if not signal then
        error("Cannot connect a slot to nil signal!")
    end

    if not slot then
        error("Cannot connect a nil slot!")
    end

    signal:addSlot(slot)
end

global function emit(signal: Signal)
    if not signal then
        error("Cannot emit a nil signal!")
    end

    signal:runSlots()
end

-- default signals:
global window_resized = Signal:new(function(data: Data): boolean
    if not data.new_size then data.new_size = window.get_size() end

    if data.new_size ~= window.get_size() then
        data.new_size = window.get_size()
        return true
    end

    return false
end)

global startup = Signal:new(function(data: Data): boolean
    if not data.started then
        data.started = true
        return true
    end

    return false
end)

global dt: number = 0
global cursor_stopped = Signal:new(function(data: Data): boolean
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

global update = Signal:new(function(_: Data): boolean
    return true
end)