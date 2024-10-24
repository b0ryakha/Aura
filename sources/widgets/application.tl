require("window")
require("layout")

global record Application is IWidget
    title: string
    args: { string }
    bg_color: Color
    --TODO: menu: Menu
end

function Application:new(title: string, size?: Vector2): Application
    local self = extends(Application, "Application", Widget, nil, "Maximum", nil)
    
    if size then
        self:resize(size)
        window.set_size(self.m_size.x, self.m_size.y)
    else
        self:resize(window.get_size())
    end

    self.title = title
    window.set_title(self.title)

    self:setLayout(Layout:new("VBox"))
    self.args = globalvars.get_args()
    self.bg_color = CachedColor:new(255, 255, 255)

    connect(window_resized, function() self:resize(window.get_size()) end)

    return self
end

-- override
function Application:render()
    render.rectangle(0, 0, self.m_size.x, self.m_size.y, self.bg_color)
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