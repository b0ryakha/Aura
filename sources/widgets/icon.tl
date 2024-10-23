require("widget")
require("oop")

global record Icon is IWidget
    sprite: Sprite
end

function Icon:new(parent: IWidget, path: string, size_policy: Policy, size?: Vector2): Icon
    local self = extends(Icon, "Icon", Widget, parent, size_policy, size)

    self.sprite = Sprite:new(path, self.size.x as integer, self.size.y as integer)

    return self
end

-- override:
function Icon:update()
    self.sprite:set_pos(self.pos.x as integer, self.pos.y as integer)
    self.sprite:set_size(self.size.x as integer, self.size.y as integer)
end

-- override:
function Icon:render()
    if not self.is_visible then return end
    render.sprite(self.sprite)
end

function Icon:setColor(color: Color)
    self.sprite:set_color(color)
end