local function fmt(format: string, ...: any): string
    local res = ""
    local args = { ... }
    local count: integer = 1

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