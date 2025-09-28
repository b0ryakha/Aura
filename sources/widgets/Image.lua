local Widget = require("Widget")
local theme = require("theme")
local fmt = require("fmt")

---@class (exact) Image: Widget
---@operator call: Image
---@field private m_color Color
---@field private m_path string
---@field private sprite Sprite
---@field private is_h_mirror boolean
---@field private is_v_mirror boolean
local Image = {}

---@param path? string
---@param size? Vector2
---@param parent? Widget
---@return Image
function Image:new(path, size, parent)
    local self = extends(self, "Image", Widget, parent, nil, size)

    self.is_h_mirror = false
    self.is_v_mirror = false
    
    self:preventFocus()

    connect(self.enabled, function()
        ---@diagnostic disable-next-line: invisible
        self.sprite:set_color(theme.accent5)
    end)

    connect(self.disabled, function()
        ---@diagnostic disable-next-line: invisible
        self.sprite:set_color(theme.foreground1)
    end)

    connect(self.sizeChanged, function()
        ---@diagnostic disable-next-line: invisible
        self:updateGeometry()
    end)

    connect(self.posChanged, function()
        ---@diagnostic disable-next-line: invisible
        self:updateGeometry()
    end)

    self:loadFromFile(path or "", self:size())
    self:setColor(theme.accent5)

    return self
end

setmetatable(Image, { __call = Image.new })

---@return string
function Image:__tostring()
    return fmt("%(path: %, color: %)", type(self), self.m_path, self.m_color)
end

---@private
function Image:updateGeometry()
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

---@override
function Image:render()
    if not self.sprite then return end
    if not self:isVisible() then return end

    render.sprite(self.sprite)
    self:parentRender()
end

---@return Color | nil
function Image:color()
    if not self.m_color then
        return nil
    end

    return self.m_color:copy()
end

---@return string
function Image:path()
    return self.m_path
end

---@param color Color
function Image:setColor(color)
    self.m_color = color

    if self.sprite then
        self.sprite:set_color(self.m_color)
    end
end

---@param alpha integer
function Image:setAlphaChannel(alpha)
    self.m_color.a = alpha
    self:setColor(self.m_color)
end

---@param path string
---@param size Vector2
function Image:loadFromFile(path, size)
    if not path then return end
    self.m_path = path

    if path == "" then
        self.sprite = nil
    else
        self:bindSize(size or Vector2:new(64, 64))
        self.sprite = Sprite:new(path, self.m_size.x, self.m_size.y)
        self:updateGeometry()
    end
end

---@param horizontal? boolean
---@param vertical? boolean
function Image:mirror(horizontal, vertical)
    self.is_h_mirror = horizontal or true
    self.is_v_mirror = vertical or false
end

return Image