local fmt = require("fmt")

local AVAILABLES = {
    Layout = require("Layout"),
    Application = require("Application"),
    Label = require("Label"),
    PushButton = require("PushButton"),
}

---@alias UIData table<string, any>
---@alias Attributes table<string, any>

---@class (exact) UIVar
---@field name string
---@field regonize fun()

---@class (exact) UINode
---@field attributes Attributes
---@field childs table<integer, UINode>
---@field content string
---@field tag string

---@class (exact) UserInterface
---@operator call: UserInterface
---@field private data UIData
---@field private vars table<integer, UIVar>
---@field private stack table<integer, string>
---@field private text string
---@field private cur_ch integer
local UserInterface = {}

---@param path string
---@return UIData
function UserInterface:new(path)
    local self = create(UserInterface, "UserInterface")

    self.data = {}
    self.vars = {}
    self.stack = {}
    self.text = self:removeComments(self:readFile(path))
    self.cur_ch = 1

    for _, node in ipairs(self:parseXml().childs) do
        self:pushWidget(node)
    end

    return self
end

setmetatable(UserInterface, { __call = UserInterface.new })

---@private
---@param path string
---@return string
function UserInterface:readFile(path)
    local xml = io.open(path, "r")
    if not xml then
        error(fmt("%: Could not be found the interface form by path: \"%\"", type(self), path))
    end

    local content = xml:read("*all")
    xml:close()

    return content:gsub("%s+", " "):match("^%s*(.-)%s*$")
end

---@generic T
---@param class T
---@param name string
---@return T
function UserInterface:get(class, name)
    local object = self.data[name]
    if not object then
        error(fmt("%: Object named \"%\" is missing!", type(self), name))
    end

    local class_type = type(class())
    if type(object) ~= class_type then
        error(fmt("%: Object named \"%\" was found, but his type \"%\" does not match expected type \"%\"!", type(self), name, type(object), class_type))
    end

    return object
end

---@private
function UserInterface:setterForField(element, class, field, value)
    local capitalized = string.upper(string.sub(field, 1, 1)) .. string.sub(field, 2)
    local method_name = "set" .. capitalized
    local method = element[method_name]
    if not method then
        error(fmt("%: Couldn't find %:%(%) method!", type(self), class, method_name, type(value)))
    end

    method(element, value)
end

---@private
---@param node UINode
---@return any
function UserInterface:pushWidget(node)
    if node.tag ~= "widget" then return end

    local T = AVAILABLES[node.attributes.class]--[[@as Widget]]
    if T == nil or T.new == nil then
        error(fmt("%: Unknown class \"%\"", type(self), node.attributes.class))
    end

    local name = node.attributes.name--[[@as string]]
    if name == nil then
        error(fmt("%: Widget with type \"%\" has no name", type(self), node.attributes.class))
    end

    local element = T:new()

    for _, child_node in ipairs(node.childs) do
        if child_node.tag == "property" then
            local prop = child_node.childs[1]
            local prop_field = child_node.attributes.name--[[@as string]]
            local prop_type = prop.tag
            local prop_val = nil

            if prop_type == "string" or prop_type == "var" then
                prop_val = prop.content
            end
            if prop_type == "number" then
                prop_val = tonumber(prop.content)
            end
            if prop_type == "rect" then
                prop_val = {}
                for _, v in ipairs(prop.childs) do
                    prop_val[v.tag] = tonumber(v.content)
                end
            end

            if prop_field == "layout" and not self.data[prop_val] then
                table.insert(self.vars, {
                    name = prop_val,
                    regonize = function()
                        self:setterForField(self.data[name], node.attributes.class, prop_field, self.data[prop_val])
                    end
                })
            else
                --TODO: fix multi call setTitle
                self:setterForField(element, node.attributes.class, prop_field, prop_val)
            end
        else
            local child = self:pushWidget(child_node)
            if child then
                element:addChild(child)
            end
        end
    end

    self.data[name] = element

    for _, var in ipairs(self.vars) do
        if name == var.name then
            var.regonize()
            break
        end
    end

    return element
end

---@private
function UserInterface:skipSpaces()
    while true do
        local ch = self.text:sub(self.cur_ch, self.cur_ch)
        if ch:match("^%s$") == nil then break end

        self.cur_ch = self.cur_ch + 1
    end
end

---@private
---@return string | nil
function UserInterface:parseTag()
    self:skipSpaces()

    local tag = ""
    local ch = self.text:sub(self.cur_ch, self.cur_ch)
    
    if ch ~= '<' or self.text:sub(self.cur_ch + 1, self.cur_ch + 1) == '/' then
        return nil
    end

    while true do
        self.cur_ch = self.cur_ch + 1

        ch = self.text:sub(self.cur_ch, self.cur_ch)
        if ch == ' ' or ch == '>' then break end

        tag = tag .. ch
    end

    --self.tag_content = self.tag_content .. '<' .. tag .. '>'

    table.insert(self.stack, tag)
    return tag
end

---@private
---@return Attributes
function UserInterface:parseAttributes()
    local tmp = ""

    while true do
        local ch = self.text:sub(self.cur_ch, self.cur_ch)
        if ch == '>' then break end

        tmp = tmp .. ch
        self.cur_ch = self.cur_ch + 1
    end

    -- skip '>'
    self.cur_ch = self.cur_ch + 1

    local attributes = {}

    for name, value in tmp:gmatch("(%w+)%s*=%s*\"(.-)\"") do
        attributes[name] = value
    end

    return attributes
end

---@private
function UserInterface:closeTag()
    if #self.stack == 0 then return end

    local tag = "</" .. self.stack[#self.stack] .. ">"
    self.cur_ch = self.cur_ch + #tag

    table.remove(self.stack, #self.stack)
end

---@private
---@param content string
---@return string
function UserInterface:removeComments(content)
    local result, _ = content:gsub("<!--.-%-%->", "")
    return result
end

---@private
---@return string
function UserInterface:parseContent()
    local result = ""

    while true do
        local ch = self.text:sub(self.cur_ch, self.cur_ch)
        if ch == '<' then break end

        self.cur_ch = self.cur_ch + 1
        result = result .. ch
    end

    return result == ' ' and "<tags>" or result
end

---@private
---@return UINode | nil
function UserInterface:parseXml()
    if self.cur_ch > #self.text then return nil end

    local tag = self:parseTag()
    if not tag then return nil end

    local attributes = self:parseAttributes()
    local content = self:parseContent()

    local childs = {}
    local child = self:parseXml()

    while child ~= nil do
        table.insert(childs, child)
        child = self:parseXml()
    end

    self:closeTag()

    return { tag = tag, attributes = attributes, childs = childs, content = content }
end

return UserInterface