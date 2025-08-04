local Align = require("Align")
local Geometry = require("Geometry")
require("oop")

local record DelegateOption
    is_selected: boolean
    is_hovered: boolean
    text: string
    rect: Geometry
    font: Font
    spacing: integer
    align: Align

-- force decl:
    metamethod __call: function<Self>(Self, is_selected: boolean, is_hovered: boolean, text: string, rect: Geometry, font: Font, spacing: integer, align: Align): DelegateOption
end

function DelegateOption:new(is_selected: boolean, is_hovered: boolean, text: string, rect: Geometry, font: Font, spacing: integer, align: Align): DelegateOption
    local self = create(DelegateOption, "DelegateOption")

    self.is_selected = is_selected
    self.is_hovered = is_hovered
    self.text = text
    self.rect = rect
    self.font = font
    self.spacing = spacing
    self.align = align

    return self
end

setmetatable(DelegateOption, { __call = DelegateOption.new })

return DelegateOption