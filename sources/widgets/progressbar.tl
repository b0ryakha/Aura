require("label")
require("orientation")

global record ProgressBar is IWidget
    label: Label
    m_format: string

    max: integer
    min: integer
    val: integer
    percent: integer

    m_orientation: Orientation
    is_inverted: boolean

    valueChanged: Signal

-- force decl:
    resetFormat: function<Self>(Self)
end

function ProgressBar:new(size?: Vector2, parent?: IWidget): ProgressBar
    local self = extends(ProgressBar, "ProgressBar", Widget, parent, nil, size)

    self.label = Label:new(nil)
    self.label:setAlignment(Align:new("Center"))
    self.label:bindPos(self.m_pos)
    self.label:bindSize(self.m_size)
    self:resetFormat()

    self.min = 0
    self.max = 100
    self.val = 0
    self.percent = 0
    self.m_orientation = "Horizontal"
    self.is_inverted = false

    self.valueChanged = Signal:new()
    
    return self
end

-- private:
function ProgressBar:processFormat(fmt: string): string
    local values = {
        ['p'] = self.percent,
        ['v'] = self.val,
        ['m'] = self.max
    }

    return (fmt:gsub("%%[pvm]", function(match: string): string
        local k = match:sub(2, 2)
        return (values as table)[k] and tostring((values as table)[k]) or match
    end))
end

-- override:
function ProgressBar:update()
    if not self.is_active then return end

    self.percent = math.floor(((self.val - self.min) / (self.max - self.min)) * 100)
    self.label:setText(self:processFormat(self.m_format))
end

-- override:
function ProgressBar:render()
    if not self.is_visible then return end

    render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, CachedColor:new(250, 250, 250), 1)
    
    local x = self.m_pos.x
    local y = self.m_pos.y
    local w = (self.percent / 100) * self.m_size.x
    local h = self.m_size.y

    if self.is_inverted then
        if self.m_orientation == "Horizontal" then
            x = self.m_pos.x + self.m_size.x - (self.percent / 100) * self.m_size.x
            w = (self.percent / 100) * self.m_size.x
        else -- Vertical:
            y = self.m_pos.y + self.m_size.y - (self.percent / 100) * self.m_size.y
            w = self.m_size.x
            h = (self.percent / 100) * self.m_size.y
        end
    else
        if self.m_orientation == "Vertical" then
            w = self.m_size.x
            h = (self.percent / 100) * self.m_size.y
        end
    end

    render.rectangle(x, y, w, h, theme.accent, 1)
    render.outline_rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, 1, theme.outline, 1)

    self.label:render()
end

function ProgressBar:invertedAppearance(): boolean
    return self.is_inverted
end

function ProgressBar:setInvertedAppearance(invert: boolean)
    self.is_inverted = invert
end

function ProgressBar:orientation(): Orientation
    return self.m_orientation
end

function ProgressBar:setOrientation(orientation: Orientation)
    self.m_orientation = orientation
end

function ProgressBar:setValue(value: integer)
    local old = self.val
    self.val = cmath.clamp(value, self.min, self.max) as integer

    if old ~= self.val then
        emit(self.valueChanged)
    end
end

function ProgressBar:reset()
    self.val = 0
    self.percent = 0
end

function ProgressBar:setMinimum(min: integer)
    self.min = min
    self:setValue(self.val)
end

function ProgressBar:setMaximum(max: integer)
    self.max = max
    self:setValue(self.val)
end

function ProgressBar:setRange(min: integer, max: integer)
    self.min = min
    self.max = max
    self:setValue(self.val)
end

function ProgressBar:format(): string
    return self.m_format
end

function ProgressBar:setFormat(fmt: string)
    self.m_format = fmt
end

function ProgressBar:resetFormat()
    self:setFormat("%p%")
end