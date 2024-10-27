local record Element
    cursor: function<Self>(Self): integer
    isHover: function<Self>(Self): boolean
end

local elements: { Element } = {}
global cursor_system: { string : function } = {}

cursor_system.add_element = function(element: any)
    table.insert(elements, element as Element)
end

cursor_system.update = function()
    local is_cursor_set = false

    for _, element in ipairs(elements) do
        local element_cursor = element:cursor()

        if element_cursor ~= cursor_type.Arrow and element:isHover() then
            cursor.change_type(element_cursor)
            is_cursor_set = true
        end
    end

    if not is_cursor_set then
        cursor.change_type(cursor_type.Arrow)
    end
end