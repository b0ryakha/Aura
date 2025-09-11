---@class (exact) CachedColor
local CachedColor = {}

local cache = {}

---@param r_or_hex string | integer
---@param g? integer
---@param b? integer
---@param a? integer
---@return Color
function CachedColor:new(r_or_hex, g, b, a)
    local cache_key = ""

    if type(r_or_hex) == "string" then
        local hex = r_or_hex
        if #hex ~= 9 then
            cache_key = hex .. "FF"
        else
            cache_key = hex
        end
    else
        local r = r_or_hex
        cache_key = string.format("#%02x%02x%02x%02x",
            cmath.clamp(r--[[@as number]], 0, 255),
            cmath.clamp(g--[[@as number]], 0, 255),
            cmath.clamp(b--[[@as number]], 0, 255),
            a and cmath.clamp(a, 0, 255) or 255
        )
    end

    cache_key = string.upper(cache_key)

    if not cache[cache_key] then
        cache[cache_key] = Color:new(cache_key)
    end

    return cache[cache_key]
end

---@param background Color
---@param foreground Color
---@param alpha integer [0.0 - 1.0]
---@return Color
function CachedColor:mixed(background, foreground, alpha)
    return CachedColor:new(
        foreground.r * alpha + background.r * (1 - alpha),
        foreground.g * alpha + background.g * (1 - alpha),
        foreground.b * alpha + background.b * (1 - alpha),
        foreground.a * alpha + background.a * (1 - alpha)
    )
end

return CachedColor