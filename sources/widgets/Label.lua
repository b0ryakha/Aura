local Widget = require("Widget")
local Align = require("Align")
local CachedFont = require("CachedFont")
local CachedColor = require("CachedColor")
local Policy = require("Policy")
local fmt = require("fmt")
local theme = require("theme")

---@class (exact) Label: Widget
---@field private m_text string
---@field private m_align Align
---@field private is_link boolean
---@field private word_wrap boolean
---
---@field private font Font
---@field private m_measure Vector2
---@field private current_color Color
---@field private default_color Color
---@field private disabled_color Color
---
---@field private is_debug boolean
---@field private debug_color Color
---@operator call: Label
local Label = {}

---@param text? string
---@param parent? Widget
---@return Label
function Label:new(text, parent)
    local self = extends(self, "Label", Widget, parent, Policy("Fixed"), nil)

    self.m_text = text or ""
    self.m_align = Align("Left", "Top")
    self.is_link = false
    self.word_wrap = false

    self:setColor(theme.foreground2)

    self.is_debug = false
    self.debug_color = CachedColor:new(cmath.rand_int(150, 255), cmath.rand_int(20, 100), cmath.rand_int(20, 100), 50)

    self:preventFocus()
    self:setFont(theme.font)
    self:tryWrap()

    connect(self.enabled, function()
        ---@diagnostic disable-next-line: invisible
        self.current_color = self.default_color:copy()
    end)

    connect(self.disabled, function()
        ---@diagnostic disable-next-line: invisible
        self.current_color = self.disabled_color:copy()
    end)
    
    return self
end

setmetatable(Label, { __call = Label.new })

---@return string
function Label:__tostring()
    return fmt("%(text: %, align: %, color: %)", type(self), self.m_text, self.m_align, self.current_color)
end

---@override
function Label:update()
    if not self:isEnabled() or not self:isVisible() then return end

    if self.is_link then
        if self:isHover() then
            self:setCursor(cursors.Hand)

            if mouse.is_pressed(buttons.Left) then
                local executer = "start"
                if globalvars.get_os_name() ~= "Windows" then
                    executer = "xdg-open"
                end

                local success, exit_code = os.execute(fmt("% %", executer, self.m_text))
                if not success then
                    error(fmt("%: The link could not be opened: \"%\", error code: %", type(self), self.m_text, exit_code))
                end
            end
        end
    end

    self:parentUpdate()
end

---@private
function Label:removeNewLines()
    self.m_text = self.m_text:gsub('\n', '')
end

---@TODO: wrap only word, not symbols
---@private
function Label:tryWrap()
    if not self.word_wrap then return end
    self:removeNewLines()

    local wrapped = ""
    local line_width = 0

    for i = 1, #self.m_text do
        local char = self.m_text:sub(i, i)
        local char_width = self.font:get_bounds(char).x

        if (line_width + char_width) >= self.m_size.x then
            wrapped = wrapped .. '\n'
            line_width = 0
        end

        wrapped = wrapped .. char
        line_width = line_width + char_width
    end

    self.m_text = wrapped
end

---@override
function Label:render()
    if not self:isVisible() then return end

    if self.is_debug then
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, self.debug_color)
    end

    if self.m_text == "" then return end

    local x = self.m_pos.x
    local y = self.m_pos.y

    if self.m_align.h == "Right" then
        x = self.m_pos.x + self.m_size.x - self.m_measure.x
    elseif self.m_align.h == "Center" then
        x = self.m_pos.x + self.m_size.x / 2 - self.m_measure.x / 2
    end

    if self.m_align.v == "Bottom" then
        y = self.m_pos.y + self.m_size.y - self.m_measure.y
    elseif self.m_align.v == "Center" then
        y = self.m_pos.y + self.m_size.y / 2 - self.m_measure.y / 2
    end

    render.text(x, y, self.font, self.m_text, self.current_color)

    self:parentRender()
end

---@param font Font
function Label:setFont(font)
    self.font = font
    self.m_measure = render.measure_text(self.font, self.m_text)
    self:resize(self.m_measure)

    if self.is_link then
        self:setStyle("l")
    end

    self:tryWrap()
end

---@return Vector2
function Label:measure()
    return self.m_measure
end

---@return string
function Label:text()
    return self.m_text
end

---@param text string
function Label:setText(text)
    self.m_text = text
    self.m_measure = render.measure_text(self.font, self.m_text)
    self:tryWrap()
end

function Label:clear()
    self.m_text = ""
    self.m_measure = Vector2:new(0, 0)
    self:tryWrap()
end

---@param is_debug? boolean
function Label:turnDebug(is_debug)
    self.is_debug = is_debug or true
end

---@return Align
function Label:alignment()
    return self.m_align
end

---@param align Align
function Label:setAlignment(align)
    self.m_align = align
    self:tryWrap()
end

---@return string Moonshine Moonshine Font style
function Label:style()
    return self.font:get_style()
end

---@param style string Moonshine Font style
function Label:setStyle(style)
    self.font = CachedFont:new(self.font:get_family(), self.font:get_size(), style)
    self:tryWrap()
end

---@param color Color
function Label:setColor(color)
    self.default_color = color
    self.disabled_color = CachedColor:mixed(theme.background2, self.default_color, 0.5)
    self.current_color = self.default_color:copy()
end

---@return Color
function Label:color()
    return self.current_color
end

function Label:makeClickable()
    self.is_link = true
    self:setStyle(self:style() .. "l")
end

---@return boolean
function Label:wordWrap()
    return self.word_wrap
end

---@param state boolean
function Label:setWordWrap(state)
    self.word_wrap = state
    
    if self.word_wrap then
        self:tryWrap()
    else
        self:removeNewLines()
    end
end

return Label