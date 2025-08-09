---@class (exact) CachedFont
local CachedFont = {}

local cache = {}

---@param name string
---@param m_size integer
---@param style? string
---@return Font
function CachedFont:new(name, m_size, style)
    style = style or ""
    local cache_key = string.upper(name .. tostring(m_size) .. style)

    if not cache[cache_key] then
        cache[cache_key] = Font:new(name, m_size, style)
    end

    return cache[cache_key]
end

return CachedFont