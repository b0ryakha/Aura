require("oop")
require("format")

global type Data = { string : any }
global type Slot = function(Data)
global type Trigger = function(data: Data): boolean

global record Signal
    title: string
    trigger: Trigger
    slots: { Slot }
    data: Data

-- force decl:
    emit: function<Self>(Self)
end

global signals: { string : Signal } = {};

function Signal:new(title: string, trigger: Trigger)
    local self = create(Signal, "Signal")
    
    self.title = title
    self.trigger = trigger
    self.slots = {}
    self.data = {}
    
    signals[title] = self
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

function Signal:emit()
    self:runSlots()
end

function Signal:addSlot(slot: Slot)
    table.insert(self.slots, slot)
end

global function process_signals()
    for _, signal in pairs(signals) do
        signal:process()
    end
end

global function connect(signal_title: string, slot: Slot)
    if signals[signal_title] then
        signals[signal_title]:addSlot(slot)
    else
        error(format("Cannot connect a callback to unknown signal: \"%\"", signal_title))
    end
end

global function emit(signal_title: string)
    if signals[signal_title] then
        signals[signal_title]:runSlots()
    else
        error(format("Cannot emit a unknown signal: \"%\"", signal_title))
    end
end