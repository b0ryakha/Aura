---@param format string
---@param ... any
---@return string
local function fmt(format, ...)
    local res = ""
    local count = 1

    local args = { ... }
    local args_len = 0
    for _, _ in pairs(args) do args_len = args_len + 1 end

    for i = 1, #format do
        if format:sub(i, i) == '%' then
            if count <= args_len then
                res = res .. tostring(args[count])
                count = count + 1
            end
        else
            res = res .. format:sub(i, i)
        end
    end

    return res
end

return fmt