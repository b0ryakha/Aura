local record CachedFont
    new: function<Self>(Self, string, integer, ?string): Font
end

local cache: { string : Font } = {}

function CachedFont:new(name: string, m_size: integer, style?: string): Font
    style = style or ""
    local cache_key = string.upper(name .. tostring(m_size) .. style)

    if not cache[cache_key] then
        cache[cache_key] = Font:new(name, m_size, style)
    end

    return cache[cache_key]
end

return CachedFont