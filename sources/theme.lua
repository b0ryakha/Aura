local CachedFont = require("CachedFont")
local CachedColor = require("CachedColor")
---@TODO: remove superfluous

---@class (exact) Theme
---@field foreground Color
---@field foreground1 Color disabled
---@field foreground2 Color default
---
---@field background Color
---@field background1 Color pressed
---@field background2 Color default
---@field background3 Color
---@field background4 Color tooltip
---@field background5 Color
---
---@field accent Color PushButton bg
---@field accent1 Color
---@field accent2 Color darked default
---@field accent3 Color default
---@field accent4 Color
---@field accent5 Color
---
---@field outline Color
---@field outline1 Color disabled
---@field outline2 Color
---@field outline3 Color default
---@field outline4 Color
---
---@field font Font
---@field font1 Font
local Theme = {}

local themes = {}
themes.dark = {
    foreground = CachedColor:new(0, 0, 0),
    foreground1 = CachedColor:new(145, 145, 145),
    foreground2 = CachedColor:new(240, 240, 240),

    background = CachedColor:new(30, 30, 30),
    background1 = CachedColor:new(35, 35, 35),
    background2 = CachedColor:new(40, 40, 40),
    background3 = CachedColor:new(50, 50, 50),
    background4 = CachedColor:new(50, 55, 60),
    background5 = CachedColor:new(60, 60, 60),

    accent = CachedColor:new(40, 45, 55),
    accent1 = CachedColor:new(35, 100, 135),
    accent2 = CachedColor:new(45, 110, 145),
    accent3 = CachedColor:new(50, 180, 250),
    accent4 = CachedColor:new(0, 0, 255),
    accent5 = CachedColor:new(255, 255, 255),

    outline = CachedColor:new(60, 60, 60),
    outline1 = CachedColor:new(70, 70, 70),
    outline2 = CachedColor:new(90, 90, 90),
    outline3 = CachedColor:new(105, 105, 105),
    outline4 = CachedColor:new(120, 120, 120),

    font = CachedFont:new("Verdana.ttf", 12)
}

local current = themes.dark
return current