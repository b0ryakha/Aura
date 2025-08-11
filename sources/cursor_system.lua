---@TODO: go to widget signal
local cursor_system = {}
local widgets = {}

-- hook:
local original = window.display
---@diagnostic disable-next-line: duplicate-set-field
_G.window.display = function()
    original()
    cursor_system.update()
end

---@param widget Widget
function cursor_system.add(widget)
    if widget.isHover then
        table.insert(widgets, widget)
    end
end

function cursor_system.update()
    local is_cursor_set = false

    for _, widget in ipairs(widgets) do
        if widget:isEnabled() and widget:isVisible() then
            local widget_cursor = widget:cursor()

            if widget_cursor ~= cursors.Arrow and widget:isHover() then
                cursor.change_type(widget_cursor)
                is_cursor_set = true
            end
        end
    end

    if not is_cursor_set then
        cursor.change_type(cursors.Arrow)
    end
end

return cursor_system