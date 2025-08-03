
local ModelIndex = require("ModelIndex")
local DelegateOption = require("DelegateOption")

local interface IDelegate
    paint: function<Self>(Self, DelegateOption, ModelIndex) -- virtual
    clear_cache: function<Self>(Self)
end

return IDelegate