local type IWidget = require("IWidget")
local Widget = require("Widget")
local Align = require("Align")
local CachedFont = require("CachedFont")
local CachedColor = require("CachedColor")
local Policy = require("Policy")
local fmt = require("fmt")
local theme = require("theme")

local record Label is IWidget
    m_text: string
    m_align: Align
    is_link: boolean
    word_wrap: boolean

    font: Font
    measure: Vector2

    is_debug: boolean
    debug_color: Color

-- force decl:
    metamethod __call: function<Self>(Self, text?: string, parent?: IWidget): Label
    setFont: function<Self>(Self, Font)
    setStyle: function<Self>(Self, string)
    tryWrap: function<Self>(Self)
end

function Label:new(text?: string, parent?: IWidget): Label
    local self = extends(Label, "Label", Widget, parent, Policy("Fixed"), nil)

    self.m_text = text or ""
    self.m_align = Align("Left", "Top")
    self.is_link = false
    self.word_wrap = false

    self.is_debug = false
    self.debug_color = CachedColor:new(cmath.rand_int(150, 255), cmath.rand_int(20, 100), cmath.rand_int(20, 100), 50)

    self:setFont(theme.regular_font)
    self:tryWrap()
    
    return self
end

-- override:
function Label:update()
    if self.is_link then
        if self:isHover() then
            self:setCursor(cursor_type.Hand)

            if mouse.is_pressed(button.Left) then
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
end

-- private:
function Label:expand()
    self.m_text = self.m_text:gsub('\n', '')
end

-- private:
function Label:tryWrap()
    if not self.word_wrap then return end
    self:expand()

    local wrapped = ""
    local line_width: number = 0

    for i = 1, #self.m_text do
        local char = self.m_text:sub(i, i)
        local char_width = self.font:get_glyph(char).x + 0.5

        if (line_width + char_width) >= self.m_size.x then
            wrapped = wrapped .. '\n'
            line_width = 0
        end

        wrapped = wrapped .. char
        line_width = line_width + char_width
    end

    self.m_text = wrapped
end

-- override:
function Label:render()
    if not self.is_visible then return end

    if self.is_debug then
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, self.debug_color)
    end

    if self.m_text == "" then return end

    local x = self.m_pos.x
    local y = self.m_pos.y

    if self.m_align.h == "Right" then
        x = self.m_pos.x + self.m_size.x - self.measure.x
    elseif self.m_align.h == "Center" then
        x = self.m_pos.x + self.m_size.x / 2 - self.measure.x / 2
    end

    if self.m_align.v == "Bottom" then
        y = self.m_pos.y + self.m_size.y - self.measure.y
    elseif self.m_align.v == "Center" then
        y = self.m_pos.y + self.m_size.y / 2 - self.measure.y / 2
    end

    render.text(x, y, self.font, self.m_text, self.is_active and theme.foreground or theme.foreground3)
end

function Label:setFont(font: Font)
    self.font = font
    self.measure = render.measure_text(self.font, self.m_text)
    self:resize(self.measure)

    if self.is_link then
        self:setStyle("l")
    end

    self:tryWrap()
end

function Label:text(): string
    return self.m_text
end

function Label:setText(text: string)
    self.m_text = text
    self.measure = render.measure_text(self.font, self.m_text)

    self:tryWrap()
end

function Label:clear()
    self:setText("")
end

function Label:turnDebug(is_debug?: boolean)
    self.is_debug = is_debug == nil and true or is_debug
end

function Label:alignment(): Align
    return self.m_align
end

function Label:setAlignment(align: Align)
    self.m_align = align
    self:tryWrap()
end

function Label:makeClickable()
    self.is_link = true
    self:setStyle("l")
end

-- style: moonshine font style
function Label:setStyle(style: string)
    self.font = CachedFont:new(self.font:get_family(), self.font:get_size(), style)
    self:tryWrap()
end

function Label:wordWrap(): boolean
    return self.word_wrap
end

function Label:setWordWrap(on: boolean)
    self.word_wrap = on
    
    if self.word_wrap then
        self:tryWrap()
    else
        self:expand()
    end
end

return Label