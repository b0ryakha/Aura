--DBG = require("externals/debugger/debugger")

-- hook:
local original = _G.type
_G.type = function(object)
    if object == nil then return "nil" end

    local mt = getmetatable(object)
    if mt and mt.__type then return mt.__type end

    return original(object)
end

---@generic T
---@param class T
---@param name string
---@return T
---@diagnostic disable-next-line: lowercase-global
function create(class, name)
    local mt = {
        __index = {},
        __type = name
    }

    for k, v in pairs(class) do
        if type(v) == "function" and string.sub(k, 1, 2) == "__" then
            mt[k] = v
        else
            mt.__index[k] = v
        end
    end

    return setmetatable({}, mt)
end

---@generic T, U
---@param child T
---@param name string
---@param base U
---@param ... any Args for base constructor
---@return T
---@diagnostic disable-next-line: lowercase-global
function extends(child, name, base, ...)
    local instance = base--[[@as any]]:new(...)
    
    local mt = getmetatable(instance)
    mt.__type = name
    mt.__base_type = type(instance)

    for k, v in pairs(child) do
        if type(v) == "function" and string.sub(k, 1, 2) == "__" then
            mt[k] = v
        else
            mt.__index[k] = v
        end
    end

    return setmetatable(instance, mt)
end