require("window")
require("layout")

global record Application is IWidget
    m_title: string
    args: { string }
    m_icon: Sprite
    --TODO: menu: Menu

-- force decl:
    layout: function<Self>(Self): Layout
    setTitle: function<Self>(Self, string)
end

function Application:new(title?: string, size?: Vector2): Application
    local self = extends(Application, "Application", Widget, nil, Policy:new("Maximum"), nil)
    
    if size then
        self:resize(size)
    else
        self:resize(window.get_size())
    end

    self:setTitle(title or "")
    self:setLayout(Layout:new("VBox"))
    self.args = globalvars.get_args()

    connect(window_resized, function()
        local win = window.get_size()
        local min = self:minSize()

        self:resize(Vector2:new(
            math.max(win.x, min.x),
            math.max(win.y, min.y)
        ))
    end)

    return self
end

-- override:
function Application:bindSize(size: Vector2)
    if not size then
        error(format("%: Cannot bind a nil size", type(self)))
    end

    self.m_size = size
    self.min_size = size
    if self.m_layout then self.m_layout:bindSize(size) end
    window.set_size(size.x, size.y)

    self:update()

    if self.m_size ~= size then
        emit(self.sizeChanged)
    end
end

-- override:
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

function Application:title(): string
    return self.m_title
end

function Application:setTitle(text: string)
    self.m_title = text
    window.set_title(self.m_title)
end