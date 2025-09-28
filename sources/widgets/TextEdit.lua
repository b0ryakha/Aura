local Widget = require("Widget")
local Label = require("Label")
local fmt = require("fmt")
local theme = require("theme")

---@class (exact) TextEdit: Widget
---@operator call: TextEdit
---@field private label Label
---@field private line_limit integer
---@field private m_text string
---@field private m_placeholder string
local TextEdit = {}

---@param placeholder_text? string
---@param size? Vector2
---@param parent? Widget
---@return TextEdit
function TextEdit:new(placeholder_text, size, parent)
    local self = extends(self, "TextEdit", Widget, parent, nil, size)

    self.label = Label(placeholder_text)
    self.label:bindPos(self.m_pos) -- fake ref
    self.label:bindSize(self.m_size)

    self.m_text = ""
    self.m_placeholder = placeholder_text or ""
    self.line_limit = 0

    connect(self.enabled, function()
        ---@diagnostic disable-next-line: invisible
        self.label:setEnabled(self:isEnabled())
    end)

    connect(self.disabled, function()
        ---@diagnostic disable-next-line: invisible
        self.label:setEnabled(self:isEnabled())
    end)

    connect(self.sizeChanged, function()
        ---@diagnostic disable-next-line: invisible
        self.label:bindSize(self.m_size)
    end)

    connect(self.posChanged, function()
        ---@diagnostic disable-next-line: invisible
        self.label:bindPos(self.m_pos)
    end)
    
    return self
end

setmetatable(TextEdit, { __call = TextEdit.new })

---@return string
function TextEdit:__tostring()
    return fmt("%(placeholder: %, size: %)", type(self), self.m_placeholder, self.m_size)
end

---@override
function TextEdit:update()
    if not self:isEnabled() or not self:isVisible() then return end

    
end

---@override
function TextEdit:render()
    if not self:isVisible() then return end


    
    self.label:render()
    self:parentRender()
end

---@protected
---@param limit integer 0 - ∞
function TextEdit:setLineLimit(limit)
    self.line_limit = limit
end

---@return string
function TextEdit:text()
    return self.m_text
end

---@param text string
function TextEdit:setText(text)
    self.m_text = text

    if not text or text == "" then
        self.label:setText(self.m_placeholder)
    else
        self.label:setText(self.m_text)
    end
end

---@return string
function TextEdit:placeholderText()
    return self.m_placeholder
end

---@param text string
function TextEdit:setPlaceholderText(text)
    self.m_placeholder = text

    if not self.m_text or self.m_text == "" then
        self.label:setText(self.m_placeholder)
    end
end

return TextEdit