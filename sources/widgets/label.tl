require("widget")
require("oop")
require("format")
require("align")

global record Label is IWidget
    text: string
    align: Align
    color: Color
    is_link: boolean

    font: Font
    measure: Vector2

    is_debug: boolean
    debug_color: Color

-- force decl:
    setFont: function<Self>(Self, Font)
    setStyle: function<Self>(Self, string)
end

function Label:new(parent: IWidget, text?: string, color?: Color): Label
    local self = extends(Label, "Label", Widget, parent)

    self.text = text or ""
    self.align = Align:new("Left", "Top")
    self.color = color or CachedColor:new(0, 0, 0)
    self.is_link = false

    self.is_debug = false
    self.debug_color = CachedColor:new(cmath.rand_int(150, 255), cmath.rand_int(20, 100), cmath.rand_int(20, 100), 100)

    self:setFont(CachedFont:new("SansSerif.ttf", 14))
    self.size = self.measure:copy()
    
    return self
end

-- override:
function Label:update()
    cursor.change_type(cursor_type.Arrow)

    if self.is_link then
        if cursor.is_bound(self.pos.x as integer, self.pos.y as integer, self.measure.x as integer, self.measure.y as integer) then
            cursor.change_type(cursor_type.Hand)

            if mouse.is_pressed(button.Left) then
                local executer = "start"
                if globalvars.get_os_name() ~= "Windows" then
                    executer = "xdg-open"
                end

                local success, exit_code = os.execute(format("% %", executer, self.text))
                if not success then
                    error(format("The link could not be opened: \"%\", error code: %", self.text, exit_code))
                end
            end
        end
    end
end

-- override:
function Label:render()
    if not self.is_visible then return end

    if self.is_debug then
        render.rectangle(
            self.pos.x as integer,
            self.pos.y as integer,
            self.size.x as integer,
            self.size.y as integer,
            self.debug_color
        )
    end

    local x = self.pos.x
    local y = self.pos.y

    if self.align.h == "Right" then
        x = self.pos.x + self.size.x - self.measure.x
    elseif self.align.h == "Center" then
        x = self.pos.x + self.size.x / 2 - self.measure.x / 2
    end

    if self.align.v == "Bottom" then
        y = self.pos.y + self.size.y - self.measure.y
    elseif self.align.v == "Center" then
        y = self.pos.y + self.size.y / 2 - self.measure.y / 2
    end

    render.text(x as integer, y as integer, self.font, self.text, self.color)
end

function Label:setFont(font: Font)
    self.font = font
    self.measure = render.measure_text(self.font, self.text)

    if self.is_link then
        self:setStyle("l")
    end
end

function Label:getText(): string
    return self.text
end

function Label:setText(text: string)
    self.text = text
    self.measure = render.measure_text(self.font, self.text)
end

function Label:turnDebug(is_debug?: boolean)
    self.is_debug = is_debug == nil and true or is_debug
end

function Label:setAlign(align: Align)
    self.align = align
end

function Label:makeClickable()
    self.is_link = true
    self:setStyle("l")
end

-- style: moonshine font style
function Label:setStyle(style: string)
    self.font = CachedFont:new(self.font:get_family(), self.font:get_size(), style)
end