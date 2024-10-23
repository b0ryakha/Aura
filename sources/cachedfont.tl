global record CachedFont
    new: function<Self>(Self, string, integer, ?string): Font
end

local cache: { string : Font } = {}

function CachedFont:new(name: string, size: integer, style?: string): Font
    style = style or ""
    local cache_key = string.upper(name .. tostring(size) .. style)

    if not cache[cache_key] then
        cache[cache_key] = Font:new(name, size, style)
    end

    return cache[cache_key]
end