require("oop")

global enum HAlign "Left" "Right" "Center" end
global enum VAlign "Top" "Bottom" "Center" end

global record Align
    h: HAlign
    v: VAlign
end

function Align:new(h: HAlign, v?: VAlign): Align
    local self = create(Align, "Align")

    self.h = h
    self.v = v or h
    
    return self
end