require("window")
require("layout")

global record Application is IWidget
    title: string
    args: { string }
    m_icon: Sprite
    --TODO: menu: Menu

-- force decl:
    layout: function<Self>(Self): Layout
end

function Application:new(title: string, size?: Vector2): Application
    local self = extends(Application, "Application", Widget, nil, "Maximum", nil)
    
    if size then
        self:resize(size)
    else
        self:resize(window.get_size())
    end

    self.title = title
    window.set_title(self.title)

    self:setLayout(Layout:new("VBox"))
    self.args = globalvars.get_args()

    connect(window_resized, function()
        local win = window.get_size()
        self:resize(Vector2:new(
            math.max(win.x, self:minSize().x),
            math.max(win.y, self:minSize().y)
        ))
    end)

    return self
end

-- override
function Application:minSize(): Vector2
    return self.m_layout:minSize()
end

-- override
function Application:resize(size: Vector2)
    if not size then
        error(format("%: Cannot set a nil size", type(self)))
    end

    self.m_size = size:copy()
    self.min_size = size:copy()
    if self.m_layout then self.m_layout:resize(size) end
    window.set_size(size.x, size.y)

    self:update()
end

-- override
function Application:bindSize(size: Vector2)
    if not size then
        error(format("%: Cannot bind a nil size", type(self)))
    end

    self.m_size = size
    self.min_size = size
    if self.m_layout then self.m_layout:bindSize(size) end
    window.set_size(size.x, size.y)

    self:update()
end

-- override
function Application:render()
    render.rectangle(0, 0, self.m_size.x, self.m_size.y, theme.background)
    self:childsRender()
end

function Application:layout(): Layout
    return self.m_layout as Layout
end

function Application:layoutType(): LayoutType
    return (self.m_layout as Layout).type
end

function Application:setLayoutType(new_type: LayoutType)
    (self.m_layout as Layout).type = new_type
end

function Application:icon(): Sprite
    return self.m_icon
end

function Application:setIcon(path_or_icon: string | Sprite)
    if type(path_or_icon) == "string" then
        self.m_icon = Sprite:new(path_or_icon as string, 64, 64)
    else
        self.m_icon = (path_or_icon as Sprite):copy()
    end

    window.set_icon(self.m_icon)
end