local Widget = require("Widget")
local Label = require("Label")
local TextInteractionFlags = require("TextInteractionFlags")
local fmt = require("fmt")
local theme = require("theme")

---@class (exact) TextEdit: Widget
---@operator call: TextEdit
---@field private label Label
---@field private line_limit integer
---@field private text_cursor integer
---@field private cursor_offset number
---@field private offset number
---@field private m_text string
---@field private m_placeholder string
---@field private cursor_timer number
---@field private is_cursor_visible boolean
---@field private default_color Color
---@field private placeholder_color Color
---@field private is_read_only boolean
---@field private flags TextInteractionFlags
---@field private selection_start integer
---@field private selection_end integer
---@field private selection_start_offset integer
---@field private selection_end_offset integer
local TextEdit = {}

---@param placeholder_text? string
---@param size? Vector2
---@param parent? Widget
---@return TextEdit
function TextEdit:new(placeholder_text, size, parent)
    local self = extends(self, "TextEdit", Widget, parent, nil, size)

    self.label = Label(placeholder_text)
    self.label:bindPos(self.m_pos) -- fake ref
    self.label:bindSize(self.m_size)

    self.default_color = theme.foreground2
    self.placeholder_color = theme.foreground1

    self:setPlaceholderText(placeholder_text or "")
    self:setText("")
    self:setTextInteractionFlags({ "Selectable", "Editable" })
    self:setSelection(0, 0)

    self.offset = 6
    self.line_limit = 0
    self.cursor_timer = 0
    self.is_cursor_visible = false
    self.is_read_only = false

    connect(self.enabled, function()
        ---@diagnostic disable-next-line: invisible
        self.label:setEnabled(self:isEnabled())
    end)

    connect(self.disabled, function()
        ---@diagnostic disable-next-line: invisible
        self.label:setEnabled(self:isEnabled())
    end)

    connect(self.sizeChanged, function()
        ---@diagnostic disable-next-line: invisible
        self.label:bindSize(self.m_size - self.offset * 2)
    end)

    connect(self.posChanged, function()
        ---@diagnostic disable-next-line: invisible
        self.label:bindPos(self.m_pos + self.offset)
    end)

    self:setCursor(cursors.Text)
    
    return self
end

setmetatable(TextEdit, { __call = TextEdit.new })

---@return string
function TextEdit:__tostring()
    return fmt("%(placeholder: %, size: %)", type(self), self.m_placeholder, self.m_size)
end

---@override
function TextEdit:render()
    if not self:isVisible() then return end

    render.rectangle(self.m_pos.x, self.m_pos.y + self.offset, self.m_size.x, self.m_size.y, theme.background2, 3)

    local accent = (self:hasFocus() or self:isHover()) and theme.accent3 or theme.outline3
    local outline = self:isEnabled() and accent or theme.outline1
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, outline, 3)

    if self.selection_start < self.selection_end then
        local extra = self.offset / 2.5
        local x = self.label:pos().x + self.selection_start_offset
        local y = self.label:pos().y - extra
        local width = self.selection_end_offset - self.selection_start_offset
        local height = self.label:measure().y + extra * 2
        render.rectangle(x, y, width, height, theme.accent3)
    end

    self.label:render()

    if self.is_cursor_visible then
        local extra = self.offset / 2.5
        local x = self.label:pos().x + self.cursor_offset
        local y = self.label:pos().y - extra
        local height = self.label:measure().y + extra * 2
        render.rectangle(x, y, 1, height, theme.accent5)
    end

    self:parentRender()
end

---@override
function TextEdit:update(dt)
    if not self:isEnabled() or not self:isVisible() or not self:hasFocus() then
        self.is_cursor_visible = false
        self:setSelection(0, 0)
        return
    end

    local delay = 1.6
    self.cursor_timer = self.cursor_timer + dt
    self.is_cursor_visible = not self.is_read_only and math.floor(self.cursor_timer / delay) % 2 == 0

    self:processMouse()
    self:processKeyboard(dt)
end

---@TODO: add delay after pinching
local lock = {}
local delay = 2.5
---@private
---@param dt number
---@param key? keys
---@return boolean | string
function TextEdit:isPressed(dt, key)
    local hash = tostring(key)
    if lock[hash] == nil then
        lock[hash] = { state = false, delay = 0 }
    end

    local symbol = nil
    if key == nil then symbol = keyboard.is_pressed()
    else symbol = keyboard.is_pressed(key) end

    if symbol then
        if not lock[hash].state or lock[hash].delay <= 0 then
            lock[hash].state = true
            if lock[hash].delay == 0 then
                lock[hash].delay = delay
            end

            return symbol
        else
            lock[hash].delay = lock[hash].delay - dt
        end
    else
        lock[hash] = nil
    end

    return false
end

---@TODO: process y_step
---@private
---@param x_step integer
---@param y_step integer
---@return integer
function TextEdit:findTextIndex(x_step, y_step)
    local result = self.text_cursor + x_step
    return result
end

---@private
---@param index integer
function TextEdit:removeSymbol(index)
    if index < 1 or index > #self.m_text then return self.m_text end
    self.m_text = self.m_text:sub(1, index - 1) .. self.m_text:sub(index + 1)
    self:updateLabel()
end

---@private
---@param index integer
---@param symbol string
function TextEdit:insertSymbol(index, symbol)
    if index < 0 or index > #self.m_text then return self.m_text end
    self.m_text = self.m_text:sub(1, index) .. symbol .. self.m_text:sub(index + 1)
    self:updateLabel()
end

---@TODO: process is_hyper
---@private
function TextEdit:processKeyboard(dt)
    local is_selection_mode = keyboard.is_pressed(keys.LShift) or keyboard.is_pressed(keys.RShift)
    local is_hyper = keyboard.is_pressed(keys.LControl) or keyboard.is_pressed(keys.RControl)

    if self:isPressed(dt, keys.Left) then
        if is_selection_mode then
            
        else
            self:setSelection(0, 0)
            self:moveCursor(self:findTextIndex(-1, 0))
        end
    elseif self:isPressed(dt, keys.Right) then
        if is_selection_mode then
            
        else
            self:setSelection(0, 0)
            self:moveCursor(self:findTextIndex(1, 0))
        end
    elseif self:isPressed(dt, keys.Up) then
        if is_selection_mode then
            
        elseif not is_hyper then
            self:setSelection(0, 0)
            self:moveCursor(self:findTextIndex(0, -1))
        end
    elseif self:isPressed(dt, keys.Down) then
        if is_selection_mode then
            
        elseif not is_hyper then
            self:setSelection(0, 0)
            self:moveCursor(self:findTextIndex(0, 1))
        end
    elseif self:isPressed(dt, keys.Backspace) then
        self:setSelection(0, 0)
        self:removeSymbol(self.text_cursor)
        self:moveCursor(self:findTextIndex(-1, 0))
    elseif self:isPressed(dt, keys.Delete) then
        self:setSelection(0, 0)
        self:removeSymbol(self.text_cursor + 1)
    else
        local symbol = self:isPressed(dt)--[[@as string]]
        if symbol then
            self:setSelection(0, 0)
            self:insertSymbol(self.text_cursor, symbol)
            self:moveCursor(self:findTextIndex(1, 0))
        end
    end

    ---@TODO: process shortcuts
end

---@private
function TextEdit:processMouse()

end

---@protected
---@param limit integer 0 ‒ ∞
function TextEdit:setLineLimit(limit)
    self.line_limit = limit
end

---@private
---@param start_index integer [0 - #text]
---@param end_index integer [start_index - #text]
function TextEdit:setSelection(start_index, end_index)
    self.selection_start = cmath.clamp(start_index, 0, #self.m_text)
    self.selection_end = cmath.clamp(end_index, start_index, #self.m_text)

    self.selection_start_offset = render.measure_text(self.label:font(), self.m_text:sub(1, self.selection_start)).x
    self.selection_end_offset = render.measure_text(self.label:font(), self.m_text:sub(1, self.selection_end)).x
end

---@param index integer [0 - #text]
function TextEdit:moveCursor(index)
    self.text_cursor = cmath.clamp(index, 0, #self.m_text)
    self.cursor_offset = render.measure_text(self.label:font(), self.m_text:sub(1, self.text_cursor)).x
end

---@param flags TextInteractionFlagsRValue
function TextEdit:setTextInteractionFlags(flags)
    self.flags = TextInteractionFlags:new(flags)
end

---@return TextInteractionFlags
function TextEdit:textInteractionFlags()
    return self.flags
end

---@return boolean
function TextEdit:isReadOnly()
    return self.is_read_only
end

---@param state? boolean default = true
function TextEdit:setReadOnly(state)
    if state == nil then state = true end
    self.is_read_only = state
end

---@return string
function TextEdit:text()
    return self.m_text
end

---@private
function TextEdit:updateLabel()
    if self.m_text == "" then
        self.label:setText(self.m_placeholder)
        self.label:setColor(self.placeholder_color)
    else
        self.label:setText(self.m_text)
        self.label:setColor(self.default_color)
    end
end

---@param text string
function TextEdit:setText(text)
    self.m_text = text
    self:moveCursor(#self.m_text)
    self:updateLabel()
end

function TextEdit:clear()
    self:setText("")
end

---@param font Font
function TextEdit:setFont(font)
    self.label:setFont(font)
    self:moveCursor(self.text_cursor)
end

---@return Font
function TextEdit:font()
    return self.label:font()
end

---@return string Moonshine Moonshine Font style
function TextEdit:style()
    return self.label:style()
end

---@param style string can store symbols: 'r' - Regular, 'b' - Bold, 'i' - Italic, 's' - StrikeThrough, default = "r"
function TextEdit:setStyle(style)
    self.label:setStyle(style)
    self:moveCursor(self.text_cursor)
end

---@return string
function TextEdit:placeholderText()
    return self.m_placeholder
end

---@param text string
function TextEdit:setPlaceholderText(text)
    self.m_placeholder = text

    if not self.m_text or self.m_text == "" then
        self.label:setText(self.m_placeholder)
        self.label:setColor(self.placeholder_color)
    end
end

return TextEdit