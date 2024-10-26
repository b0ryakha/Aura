require("cachedfont")
require("cachedcolor")

global record Theme
    default: Color
    hovered: Color
    pressed: Color
    outline: Color
    accent: Color
    font: Font
    foreground: Color
end

local themes: { string : Theme } = {
    light = {
        default = CachedColor:new("#F0F0F0"),
        hovered = CachedColor:new("#FAFAFA"),
        pressed = CachedColor:new("#E6E6E6"),
        outline = CachedColor:new("#969696"),
        accent = CachedColor:new("#B4DCFF"),
        font = CachedFont:new("SansSerif.ttf", 13),
        foreground = CachedColor:new("#000000")
    },

    dark = {},
}

global theme = themes.light