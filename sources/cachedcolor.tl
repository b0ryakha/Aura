global record CachedColor
    new: function<Self>(Self, integer | string, ?integer, ?integer, ?integer): Color
end

local cache: { string : Color } = {}

function CachedColor:new(r_or_hex: integer | string, g?: integer, b?: integer, a?: integer): Color
    local cache_key = ""

    if type(r_or_hex) == "string" then
        local hex = r_or_hex as string
        if #hex ~= 9 then
            cache_key = hex .. "FF"
        else
            cache_key = hex
        end
    else
        local r = r_or_hex as number
        cache_key = string.format("#%02x%02x%02x%02x",
            cmath.clamp(r, 0, 255),
            cmath.clamp(g, 0, 255),
            cmath.clamp(b, 0, 255),
            a and cmath.clamp(a, 0, 255) or 255
        )
    end

    cache_key = string.upper(cache_key)

    if not cache[cache_key] then
        cache[cache_key] = Color:new(cache_key)
    end

    return cache[cache_key]
end