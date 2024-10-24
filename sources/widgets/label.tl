require("widget")
require("format")
require("align")

global record Label is IWidget
    m_text: string
    m_align: Align
    color: Color
    is_link: boolean
    --TODO: word_wrap: boolean

    font: Font
    measure: Vector2

    is_debug: boolean
    debug_color: Color

-- force decl:
    setFont: function<Self>(Self, Font)
    setStyle: function<Self>(Self, string)
end

function Label:new(text?: string, color?: Color, parent?: IWidget): Label
    local self = extends(Label, "Label", Widget, parent, "Fixed", nil)

    self.m_text = text or ""
    self.m_align = Align:new("Left", "Top")
    self.color = color or CachedColor:new(0, 0, 0)
    self.is_link = false

    self.is_debug = false
    self.debug_color = CachedColor:new(cmath.rand_int(150, 255), cmath.rand_int(20, 100), cmath.rand_int(20, 100), 100)

    self:setFont(CachedFont:new("SansSerif.ttf", 14))
    self:resize(self.measure)
    
    return self
end

-- override:
function Label:update()
    self:setCursor(cursor_type.Arrow)

    if self.is_link then
        if self:isHover() then
            self:setCursor(cursor_type.Hand)

            if mouse.is_pressed(button.Left) then
                local executer = "start"
                if globalvars.get_os_name() ~= "Windows" then
                    executer = "xdg-open"
                end

                local success, exit_code = os.execute(format("% %", executer, self.m_text))
                if not success then
                    error(format("The link could not be opened: \"%\", error code: %", self.m_text, exit_code))
                end
            end
        end
    end
end

-- override:
function Label:render()
    if not self.is_visible then return end

    if self.is_debug then
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, self.debug_color)
    end

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

    render.text(x, y, self.font, self.m_text, self.color)
end

function Label:setFont(font: Font)
    self.font = font
    self.measure = render.measure_text(self.font, self.m_text)

    if self.is_link then
        self:setStyle("l")
    end
end

function Label:text(): string
    return self.m_text
end

function Label:setText(text: string)
    self.m_text = text
    self.measure = render.measure_text(self.font, self.m_text)
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
end

function Label:makeClickable()
    self.is_link = true
    self:setStyle("l")
end

-- style: moonshine font style
function Label:setStyle(style: string)
    self.font = CachedFont:new(self.font:get_family(), self.font:get_size(), style)
end