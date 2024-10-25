require("widget")

global record Image is IWidget
    m_color: Color
    sprite: Sprite
    is_h_mirror: boolean
    is_v_mirror: boolean

-- force decl:
    loadFromFile: function<Self>(Self, string)
end

function Image:new(path?: string, size?: Vector2, parent?: IWidget): Image
    local self = extends(Image, "Image", Widget, parent, nil, size)

    self.is_h_mirror = false
    self.is_v_mirror = false
    self:loadFromFile(path)

    return self
end

-- override:
function Image:update()
    if not self.sprite then return end

    self.sprite:set_pos(
        (self.is_h_mirror and 1.5 or 1) * self.m_pos.x,
        (self.is_v_mirror and 1.5 or 1) * self.m_pos.y
    )

    self.sprite:set_size(
        (self.is_h_mirror and -1 or 1) * self.m_size.x,
        (self.is_v_mirror and -1 or 1) * self.m_size.y
    )
end

-- override:
function Image:render()
    if not self.sprite then return end
    if not self.is_visible then return end

    render.sprite(self.sprite)
end

function Image:color(): Color
    return self.m_color:copy()
end

function Image:setColor(color: Color)
    self.m_color = color

    if self.sprite then
        self.sprite:set_color(self.m_color)
    end
end

function Image:setAlphaChannel(alpha: integer)
    self.m_color.a = alpha
    self:setColor(self.m_color)
end

function Image:loadFromFile(path: string)
    if not path then return end
    self.sprite = Sprite:new(path, self.m_size.x, self.m_size.y)
end

function Image:mirror(horizontal?: boolean, vertical?: boolean)
    self.is_h_mirror = (horizontal ~= nil) and horizontal or true
    self.is_v_mirror = (vertical ~= nil) and horizontal or false
end