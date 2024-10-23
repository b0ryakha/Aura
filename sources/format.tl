global function format(fmt: string, ...: any): string
    local res = ""
    local args = { ... }
    local count: integer = 1

    for i = 1, #fmt do
        if fmt:sub(i, i) == '%' then
            if count <= #args then
                res = res .. tostring(args[count])
                count = count + 1
            end
        else
            res = res .. fmt:sub(i, i)
        end
    end

    return res
end