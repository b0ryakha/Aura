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
    return setmetatable({}, {
        __index = class,
        __type = name,
        __tostring = class--[[@as any]].__tostring,
        __eq = class--[[@as any]].__eq,
    })
end

---@generic T, U
---@param child T
---@param name string
---@param base U
---@param ... any Args for base constructor
---@return T
---@diagnostic disable-next-line: lowercase-global
function extends(child, name, base, ...)
    local index = {}

    for k, v in pairs(base) do index[k] = v end
    for k, v in pairs(child) do index[k] = v end

    return setmetatable(base--[[@as any]]:new(...), {
        __index = index,
        __type = name,
        __base_type = type(base)
    })
end