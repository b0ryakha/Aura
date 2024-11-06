require("oop")
require("format")

--global dbg = require("externals/debugger/debugger") as Debugger

local type Attributes = { string : any }

local record UINode
    attributes: Attributes
    childs: { UINode }
    content: string
    tag: string
end

global record UserInterface
    stack: { string }
    text: string
    cur_ch: integer

-- force decl:
    removeComments: function<Self>(Self, string): string
    printNodes: function<Self>(Self, UINode)
    readFile: function<Self>(Self, string): string
    parseXml: function<Self>(Self): UINode
end

function UserInterface:new(path: string): UINode
    local self = create(UserInterface, "UserInterface")

    self.stack = {}
    self.text = self:removeComments(self:readFile(path))
    self.cur_ch = 1

    local nodes = self:parseXml()
    self:printNodes(nodes)

    return nodes
end

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
function UserInterface:printNodes(node: UINode)
    print("Tag: " .. node.tag)

    if next(node.attributes) ~= nil then
        print("Attributes:")
        for k, v in pairs(node.attributes) do
            print(format("  %: %", k, v))
        end
    end

    local childs = ""
    for _, child in ipairs(node.childs) do
        childs = childs .. format("%(name:%), ", child.tag, child.attributes.name or "")
    end
    if childs ~= "" then
        print("Childs: " .. childs:sub(1, #childs - 2))
    end

    print(format("Content: \"%\"\n", node.content))

    for _, child in ipairs(node.childs) do
        self:printNodes(child)
    end
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