---@param format string
---@param ... any
---@return string
local function fmt(format, ...)
    local res = ""
    local args = { ... }
    local count = 1

    for i = 1, #format do
        if format:sub(i, i) == '%' then
            if count <= #args then
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