require("widget")
require("oop")
require("label")
require("policy")
require("frame")

global record ProgressBar is IWidget
    label: Label
    percent: integer
    accent_color: Color
    frame: Frame

-- force decl:
    setPercent: function<Self>(Self, integer)
end

function ProgressBar:new(parent: IWidget, policy?: Policy, size?: Vector2, percent?: integer): ProgressBar
    local self = extends(ProgressBar, "ProgressBar", Widget, parent, policy, size)

    self.label = Label:new(nil)
    self.label:setAlign(Align:new("Center"))
    self.label:setPos(self.pos) -- by ref
    self.label:setSize(self.size) -- by ref

    self.frame = Frame:new(nil)
    self.frame:setPos(self.pos) -- by ref
    self.frame:setSize(self.size) -- by ref

    self:setPercent(percent or 0)
    self.accent_color = CachedColor:new(50, 150, 215)
    
    return self
end

-- override:
function ProgressBar:update()
    self.label:setText(tostring(self.percent) .. '%')
end

-- override:
function ProgressBar:render()
    if not self.is_visible then return end

    render.rectangle(
        self.pos.x as integer,
        self.pos.y as integer,
        self.size.x as integer,
        self.size.y as integer,
        CachedColor:new(250, 250, 250),
        1
    )
    
    render.rectangle(
        self.pos.x as integer,
        self.pos.y as integer,
        cmath.round(self.size.x * (self.percent / 100)),
        self.size.y as integer,
        self.accent_color,
        1
    )

    self.frame:render()
    self.label:render()
end

function ProgressBar:setAccentColor(color: Color)
    self.accent_color = color
end

function ProgressBar:setPercent(percent: integer)
    self.percent = cmath.clamp(percent, 0, 100) as integer
end