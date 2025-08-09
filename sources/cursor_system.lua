---@TODO: go to widget signal
local cursor_system = {}

local elements = {}

---@class (exact) CursosElement
local CursosElement = {}

---@return integer
---@diagnostic disable-next-line: missing-return
function CursosElement:cursor() end

---@return boolean
---@diagnostic disable-next-line: missing-return
function CursosElement:isHover() end

-- hook:
local original = window.display
---@diagnostic disable-next-line: duplicate-set-field
_G.window.display = function()
    original()
    cursor_system.update()
end

---@param element CursosElement
function cursor_system.add_element(element)
    if element.isHover then
        table.insert(elements, element)
    end
end

function cursor_system.update()
    local is_cursor_set = false

    for _, element in ipairs(elements) do
        local element_cursor = element:cursor()

        if element_cursor ~= cursors.Arrow and element:isHover() then
            cursor.change_type(element_cursor)
            is_cursor_set = true
        end
    end

    if not is_cursor_set then
        cursor.change_type(cursors.Arrow)
    end
end

return cursor_system