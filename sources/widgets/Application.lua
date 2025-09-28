local Policy = require("Policy")
local Widget = require("Widget")
local Layout = require("Layout")
local fmt = require("fmt")
local theme = require("theme")
local deltatime = require("externals/deltatime/deltatime")
local dt = 0

---@class (exact) Application: Widget
---@operator call: Application
---@field private m_title string
---@field private args table<integer, string>
---@field private m_icon Sprite
---@TODO: menu: Menu
local Application = {}

---@param title? string
---@param size? Vector2
---@return Application
function Application:new(title, size)
    local self = extends(self, "Application", Widget, nil, Policy("Maximum"), nil)
    
    if size then
        self:resize(size)
    else
        self:resize(window.get_size())
    end

    if title then
        self:setTitle(title)
    end

    self:preventFocus()
    self:setLayout(Layout("VBox"))
    self.args = globalvars.get_args()

    connect(window_resized, function()
        ---@diagnostic disable-next-line: invisible
        self.m_size = window.get_size()
        local min = self:minSize()

        self:resize(Vector2:new(
            ---@diagnostic disable-next-line: invisible
            math.max(self.m_size.x, min.x),
            ---@diagnostic disable-next-line: invisible
            math.max(self.m_size.y, min.y)
        ))
    end)

    connect(self.sizeChanged, function()
        ---@diagnostic disable-next-line: invisible
        window.set_size(self.m_size.x, self.m_size.y)
    end)

    return self
end

setmetatable(Application, { __call = Application.new })

---@return string
function Application:__tostring()
    return fmt("%(title: %)", type(self), self.m_title)
end

---@return number
function Application:deltaTime()
    return dt
end

---@override
function Application:update()
    dt = deltatime.getTime()
    self:parentUpdate(dt)
end

---@override
function Application:render()
    render.rectangle(0, 0, self.m_size.x, self.m_size.y, theme.background2)
    self:parentRender()
end

---@return Layout
function Application:layout()
    return self.m_layout
end

---@return Layout.Type
function Application:layoutType()
    return self.m_layout:layoutType()
end

---@param new_type Layout.Type
function Application:setLayoutType(new_type)
    self.m_layout:setLayoutType(new_type)
end

---@return Sprite
function Application:icon()
    return self.m_icon
end

---@param path_or_icon string | Sprite
function Application:setIcon(path_or_icon)
    if type(path_or_icon) == "string" then
        self.m_icon = Sprite:new(path_or_icon--[[@as string]], 64, 64)
    else
        self.m_icon = path_or_icon--[[@as Sprite]]:copy()
    end

    window.set_icon(self.m_icon)
end

---@return string
function Application:title()
    return self.m_title
end

---@param title string
function Application:setTitle(title)
    self.m_title = title
    window.set_title(title)
end

return Application