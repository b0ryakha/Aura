local CachedFont = require("CachedFont")
local CachedColor = require("CachedColor")

---@class (exact) Theme
---@field background Color
---@field background2 Color
---@field background3 Color
---@field background4 Color
---@field background5 Color
---@field foreground Color
---@field foreground2 Color
---@field foreground3 Color
---@field foreground4 Color
---@field default Color
---@field hovered Color
---@field pressed Color
---@field outline Color
---@field outline2 Color
---@field accent Color
---@field light_accent Color
---@field dark_accent Color
---
---@field regular_font Font
---@field small_font Font
local Theme = {}

local themes = {}
themes.light = {
    background = CachedColor:new(245, 245, 245),
    background2 = CachedColor:new(240, 240, 240),
    background3 = CachedColor:new(35, 35, 35),
    background4 = CachedColor:new(255, 255, 255),
    background5 = CachedColor:new(80, 80, 80),

    foreground = CachedColor:new(0, 0, 0),
    foreground2 = CachedColor:new(20, 20, 20),
    foreground3 = CachedColor:new(215, 215, 215),
    foreground4 = CachedColor:new(60, 60, 60),

    default = CachedColor:new(240, 240, 240),
    hovered = CachedColor:new(254, 254, 254),
    pressed = CachedColor:new(235, 235, 235),
    outline = CachedColor:new(215, 215, 215),
    outline2 = CachedColor:new(150, 150, 150),
    accent = CachedColor:new(180, 220, 255),
    dark_accent = CachedColor:new(140, 180, 215),
    light_accent = CachedColor:new(220, 250, 255),

    regular_font = CachedFont:new("SansSerif.ttf", 14),
    small_font = CachedFont:new("SansSerif.ttf", 12)
}

local current = themes.light
return current