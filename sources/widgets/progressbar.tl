require("widget")
require("oop")
require("label")
require("policy")

global record ProgressBar is IWidget
    label: Label
    percent: integer
    accent_color: Color

-- force decl:
    setPercent: function<Self>(Self, integer)
end

function ProgressBar:new(parent: IWidget, policy?: Policy, size?: Vector2, percent?: integer): ProgressBar
    local self = extends(ProgressBar, "ProgressBar", Widget, parent, policy, size)

    self.label = Label:new(nil)
    self.label:setAlign(Align:new("Center"))
    self.label:setPos(self.pos) -- by ref
    self.label:setSize(self.size) -- by ref

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

    render.rectangle(self.pos.x, self.pos.y, self.size.x, self.size.y, CachedColor:new(250, 250, 250), 1)
    render.rectangle(self.pos.x, self.pos.y, cmath.round(self.size.x * (self.percent / 100)), self.size.y, self.accent_color, 1)
    render.outline_rectangle(self.pos.x, self.pos.y, self.size.x, self.size.y, 1, CachedColor:new(150, 150, 150), 1)

    self.label:render()
end

function ProgressBar:setAccentColor(color: Color)
    self.accent_color = color
end

function ProgressBar:setPercent(percent: integer)
    self.percent = cmath.clamp(percent, 0, 100) as integer
end