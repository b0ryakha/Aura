local Window = require("Window")
local Label = require("Label")
local Align = require("Align")
require("oop")

---@class (exact) ToolTip: Widget
---@operator call: ToolTip
---@field private is_visible boolean
---@field private duration number
---@field private init_cursor_pos Vector2
---@field private label Label
---@field private window Window
local ToolTip = {}

---@param text? string
---@return ToolTip
function ToolTip:new(text)
    local self = create(ToolTip, "ToolTip")

    self.label = Label(text)
    self.label:setAlignment(Align("Center"))

    self.window = Window()

    connect(cursor_stopped, function(data)
        ---@diagnostic disable-next-line: invisible
        self.duration = data.duration--[[@as number]]
    end)

    return self
end

setmetatable(ToolTip, { __call = ToolTip.new })

---@param is_hover boolean
function ToolTip:update(is_hover)
    if self.duration > 10 then
        self.is_visible = false
        return
    end

    if not self.is_visible then
        if self.duration > 0.5 and is_hover then
            self.is_visible = true
            self.init_cursor_pos = cursor.get_pos()
        else
            return
        end
    elseif not is_hover then
        self.is_visible = false
        return
    end

    local measure = self.label:measure()
    local cursor_size = 16
    local offset = 4

    self.window:setPos(self.init_cursor_pos + cursor_size)
    self.window:resize(measure + offset * 2)
    self.label:setPos(self.init_cursor_pos + cursor_size)
    self.label:resize(measure + offset * 2)
end

---@TODO: add shadow for window
function ToolTip:render()
    if not self.is_visible then return end

    self.window:render()
    self.label:render()
end

---@return string
function ToolTip:text()
    return self.label:text()
end

return ToolTip