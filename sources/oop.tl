local interface IClass
    __type: string
    __base_type: string
    new: function<Self>(Self, ...: any)
end

-- hook:
global original_type = _G.type
_G.type = function(object: any): string
    if object == nil then return "nil" end

    local mt = getmetatable(object) as IClass
    if mt and mt.__type then return mt.__type end

    return original_type(object)
end

global function instanceof<T, U>(self: T, object: U): boolean
    return (getmetatable(self) as IClass).__base_type == type(object)
end

global function create<T>(class: T, name: string): T
    local mt = { __index = class, __type = name }
    return setmetatable({}, mt) as T
end

global function extends<Child>(child: Child, name: string, base: any, ...: any): Child
    local index = {}
    
    for k, v in pairs(base as table) do index[k] = v end
    for k, v in pairs(child as table) do index[k] = v end

    local mt = { __index = index, __type = name, __base_type = type(base) }

    return setmetatable((base as IClass):new(...), mt)
end