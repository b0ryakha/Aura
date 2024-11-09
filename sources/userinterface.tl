require("oop")
require("format")

require("application")
require("image")
require("label")
require("layout")
require("spacer")
require("widget")
require("window")
require("groupbox")
require("progressbar")
require("pushbutton")
require("checkbox")

--global dbg = require("externals/debugger/debugger") as Debugger

global type UIData = { string : IWidget }
local type Attributes = { string : any }

local record UIVar
    name: string
    regonize: function
end

local record UINode
    attributes: Attributes
    childs: { UINode }
    content: string
    tag: string
end

global record UserInterface
    data: UIData
    vars: { UIVar }
    stack: { string }
    text: string
    cur_ch: integer

-- force decl:
    removeComments: function<Self>(Self, string): string
    pushWidget: function<Self>(Self, UINode): any
    readFile: function<Self>(Self, string): string
    parseXml: function<Self>(Self): UINode
end

function UserInterface:new(path: string): UIData
    local self = create(UserInterface, "UserInterface")

    self.data = {}
    self.vars = {}
    self.stack = {}
    self.text = self:removeComments(self:readFile(path))
    self.cur_ch = 1

    for _, node in ipairs(self:parseXml().childs) do
        self:pushWidget(node)
    end

    return self.data
end

-- private:
function UserInterface:readFile(path: string): string
    local xml = io.open(path, "r")
    if not xml then
        error(format("[UserInterface] Could not be found the interface form by path: \"%\"", path))
    end

    local content = xml:read("*all")
    xml:close()

    return content:gsub("%s+", " "):match("^%s*(.-)%s*$")
end

-- private:
function UserInterface:pushWidget(node: UINode): any
    if node.tag ~= "widget" then return end

    local T = (_G as table)[node.attributes.class] as Widget
    if T == nil or T.new == nil then
        error(format("[UserInterface] Unknown class \"%\"", node.attributes.class))
    end

    local name = node.attributes.name as string
    if name == nil then
        error(format("[UserInterface] Widget with type \"%\" has no name", node.attributes.class))
    end

    local element = T:new()

    for _, child_node in ipairs(node.childs) do
        if child_node.tag == "property" then
            local prop = child_node.childs[1]
            local prop_field = child_node.attributes.name as string
            local prop_type = prop.tag
            local prop_val: any = nil

            if prop_type == "string" or prop_type == "var" then
                prop_val = prop.content
            end
            if prop_type == "number" then
                prop_val = tonumber(prop.content)
            end
            if prop_type == "rect" then
                prop_val = {}
                for _, v in ipairs(prop.childs) do
                    (prop_val as table)[v.tag] = tonumber(v.content)
                end
            end

            if prop_field == "text" then
                (element as Label):setText(prop_val as string)
            end
            if prop_field == "title" then
                (element as Application):setTitle(prop_val as string)
            end
            if prop_field == "layout" then
                local layout = self.data[prop_val as string]
                if layout then
                    element:setLayout(layout)
                else
                    table.insert(self.vars, { name = prop_val as string, regonize = function()
                        self.data[name]:setLayout(self.data[prop_val as string])
                    end})
                end
            end
            if prop_field == "geometry" then
                element:setGeometry(prop_val as Geometry)
            end
        else
            local child = self:pushWidget(child_node) as IWidget
            if child then
                (element as Widget):addChild(child)
            end
        end
    end

    self.data[name] = element as IWidget

    for _, var in ipairs(self.vars) do
        if name == var.name then
            var.regonize()
            break
        end
    end

    return element
end

-- private:
function UserInterface:skipSpaces()
    while true do
        local ch = self.text:sub(self.cur_ch, self.cur_ch)
        if ch:match("^%s$") == nil then break end

        self.cur_ch = self.cur_ch + 1
    end
end

-- private:
function UserInterface:parseTag(): string
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

-- private:
function UserInterface:parseAttributes(): Attributes
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

-- private:
function UserInterface:closeTag()
    if #self.stack == 0 then return end

    local tag = "</" .. self.stack[#self.stack] .. ">"
    self.cur_ch = self.cur_ch + #tag

    table.remove(self.stack, #self.stack)
end

-- private:
function UserInterface:removeComments(content: string): string
    return content:gsub("<!--.-%-%->", "") as string
end

-- private:
function UserInterface:parseContent(): string
    local result = ""

    while true do
        local ch = self.text:sub(self.cur_ch, self.cur_ch)
        if ch == '<' then break end

        self.cur_ch = self.cur_ch + 1
        result = result .. ch
    end

    return result == ' ' and "<tags>" or result
end

-- private:
function UserInterface:parseXml(): UINode
    if self.cur_ch > #self.text then return nil end

    local tag = self:parseTag()
    if not tag then return nil end

    local attributes = self:parseAttributes()
    local content = self:parseContent()

    local childs: { UINode } = {}
    local child = self:parseXml()

    while child ~= nil do
        table.insert(childs, child)
        child = self:parseXml()
    end

    self:closeTag()

    return { tag = tag, attributes = attributes, childs = childs, content = content }
end