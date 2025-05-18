require("widget")
require("margins")
require("layouttype")

--global dbg = require("externals/debugger/debugger") as Debugger

global record Layout is IWidget
    type: LayoutType
    m_margins: Margins
    m_spacing: number

    is_debug: boolean
    debug_color: Color
end

function Layout:new(align_type?: LayoutType, size?: Vector2, parent?: IWidget): Layout
    local self = extends(Layout, "Layout", Widget, parent, Policy:new("Maximum"), size)

    if self.m_parent and type(self.m_parent) ~= "Layout" then
        self.m_parent:setLayout(self)
    end

    self.type = align_type or "HBox"
    self.m_margins = Margins:new(9, 9, 9, 9)
    self.m_spacing = 6

    self.is_debug = false
    self.debug_color = CachedColor:new(cmath.rand_int(150, 255), cmath.rand_int(20, 100), cmath.rand_int(20, 100), 100)

    return self
end

-- private:
function Layout:warp(child: IWidget)
    if child.size_policy.h ~= "Fixed" then
        local right_edge = self.m_pos.x + self.m_size.x - self.m_margins.right
        if (child.m_pos.x + child.m_size.x) >= right_edge then
            child.m_size.x = child.m_size.x - (child.m_pos.x + child.m_size.x - right_edge)
        end
    end
    
    if child.size_policy.v ~= "Fixed" then
        local bottom_edge = self.m_pos.y + self.m_size.y - self.m_margins.bottom
        if (child.m_pos.y + child.m_size.y) >= bottom_edge then
            child.m_size.y = child.m_size.y - (child.m_pos.y + child.m_size.y - bottom_edge)
        end
    end
end

-- private:
function Layout:hAlign()
    local total_width = self.m_size.x - self.m_margins.left - self.m_margins.right
    local total_height = self.m_size.y - self.m_margins.top - self.m_margins.bottom
    
    local fixed_width: number = 0
    local warp_count = 0

    for _, child in ipairs(self.childs) do
        if child.size_policy.h ~= "Fixed" then
            warp_count = warp_count + 1
        else
            fixed_width = fixed_width + child.m_size.x
        end
    end

    local flexible_width = total_width - fixed_width
    local total_children_width: number = 0
    local max_children_count = 0

    for _, child in ipairs(self.childs) do
        if warp_count > 0 then
            local new_width = flexible_width / warp_count
            
            if child.size_policy.h == "Maximum" then
                child.m_size.x = math.max(child.min_size.x, new_width)
                max_children_count = max_children_count + 1
            elseif child.size_policy.h == "Minimum" then
                child.m_size.x = math.min(child.min_size.x, new_width)
            end
        end
        
        if child.size_policy.v == "Maximum" then
            child.m_size.y = total_height
        elseif child.size_policy.v == "Minimum" then
            child.m_size.y = math.min(child.min_size.y, total_height)
        end

        if child.size_policy.h ~= "Maximum" then
            total_children_width = total_children_width + child.m_size.x
        end
    end

    if max_children_count > 0 then
        local remaining_width = total_width - total_children_width - (max_children_count - 1) * self.m_spacing
        local new_width = remaining_width / max_children_count

        for _, child in ipairs(self.childs) do
            if child.size_policy.h == "Maximum" then
                child.m_size.x = new_width
                total_children_width = total_children_width + child.m_size.x
            end
        end
    end

    local offset = (total_width - total_children_width - (warp_count - 1) * self.m_spacing) / 2
    local current_x = self.m_pos.x + self.m_margins.left + math.max(0, offset)

    for i, child in ipairs(self.childs) do
        child.m_pos.x = current_x
        child.m_pos.y = self.m_pos.y + self.m_margins.top + (total_height - child.m_size.y) / 2

        current_x = current_x + child.m_size.x
        if i < #self.childs then
            current_x = current_x + self.m_spacing
        end

        self:warp(child)
    end
end

-- private:
function Layout:vAlign()
    local total_width = self.m_size.x - self.m_margins.left - self.m_margins.right
    local total_height = self.m_size.y - self.m_margins.top - self.m_margins.bottom
    
    local fixed_height: number = 0
    local warp_count = 0

    for _, child in ipairs(self.childs) do
        if child.size_policy.v ~= "Fixed" then
            warp_count = warp_count + 1
        else
            fixed_height = fixed_height + child.m_size.y
        end
    end

    local flexible_height = total_height - fixed_height
    local total_children_height: number = 0
    local max_children_count = 0

    for _, child in ipairs(self.childs) do
        if warp_count > 0 then
            local new_height = flexible_height / warp_count
            
            if child.size_policy.v == "Maximum" then
                child.m_size.y = math.max(child.min_size.y, new_height)
                max_children_count = max_children_count + 1
            elseif child.size_policy.v == "Minimum" then
                child.m_size.y = math.min(child.min_size.y, new_height)
            end
        end
        
        if child.size_policy.h == "Maximum" then
            child.m_size.x = total_width
        elseif child.size_policy.h == "Minimum" then
            child.m_size.x = math.min(child.min_size.x, total_width)
        end

        if child.size_policy.v ~= "Maximum" then
            total_children_height = total_children_height + child.m_size.y
        end
    end

    if max_children_count > 0 then
        local remaining_height = total_height - total_children_height - (max_children_count - 1) * self.m_spacing
        local new_height = remaining_height / max_children_count

        for _, child in ipairs(self.childs) do
            if child.size_policy.v == "Maximum" then
                child.m_size.y = new_height
                total_children_height = total_children_height + child.m_size.y
            end
        end
    end

    local offset = (total_height - total_children_height - (warp_count - 1) * self.m_spacing) / 2
    local current_y = self.m_pos.y + self.m_margins.top + math.max(0, offset)

    for i, child in ipairs(self.childs) do
        child.m_pos.y = current_y
        child.m_pos.x = self.m_pos.x + self.m_margins.left + (total_width - child.m_size.x) / 2

        current_y = current_y + child.m_size.y
        if i < #self.childs then
            current_y = current_y + self.m_spacing
        end

        self:warp(child)
    end
end

-- override:
function Layout:update()
    if not self.is_active then return end

    local old_pos: { Vector2 } = {}
    local old_size: { Vector2 } = {}
    for i, child in ipairs(self.childs) do
        old_pos[i] = child:pos()
        old_size[i] = child:size()
    end

    if self.type == "HBox" then self:hAlign() end
    if self.type == "VBox" then self:vAlign() end
    if self.type == "Grid" then error("Layout: not impl") end

    for i, child in ipairs(self.childs) do
        child:update()
        if old_pos[i] ~= child:pos() then emit(child.posChanged) end
        if old_size[i] ~= child:size() then emit(child.sizeChanged) end
    end
end

-- override:
function Layout:render()
    if not self.is_visible then return end

    if self.is_debug then
        render.rectangle(self.m_pos.x, self.m_pos.y, self.m_size.x, self.m_size.y, self.debug_color)
    end

    self:childsRender()
end

function Layout:addItem(item: IWidget)
    if not item then
        error(format("%: Cannot add a nil item", type(self)))
    end

    self:addChild(item)
end

function Layout:itemAt(index: integer): IWidget
    return self:childAt(index)
end

function Layout:removeItem(item: IWidget)
    for k, child in ipairs(self.childs) do
        if child == item then
            table.remove(self.childs, k)
            break
        end
    end
end

function Layout:replaceItem(from: IWidget, to: IWidget)
    for k, child in ipairs(self.childs) do
        if child == from then
            self.childs[k] = to
            break
        end
    end
end

function Layout:spacing(): number
    return self.m_spacing
end

function Layout:setSpacing(spacing: number)
    self.m_spacing = spacing
end

function Layout:margins(): Margins
    return self.m_margins:copy()
end

function Layout:setMargins(margins: Margins)
    self.m_margins = margins:copy()
end

function Layout:layoutType(): LayoutType
    return self.type
end

function Layout:setLayoutType(new_type: LayoutType)
    self.type = new_type
end

function Layout:indexOf(widget: IWidget): integer
    if not widget then return -1 end

    for i, child in ipairs(self.childs) do
        if child == widget then return i end
    end

    return -1
end

function Layout:count(): integer
    return #self.childs
end

function Layout:turnDebug(is_debug?: boolean)
    self.is_debug = is_debug == nil and true or is_debug
end

-- override:
function Layout:minSize(): Vector2
    local result = Vector2:new(self.m_margins.left + self.m_margins.right, self.m_margins.top + self.m_margins.bottom)
    if #self.childs == 0 then return result end

    for _, child in ipairs(self.childs) do
        local min = child:minSize()

        if self.type == "HBox" then
            result.x = result.x + min.x
            result.y = math.max(result.y, result.y + min.y)
        elseif self.type == "VBox" then
            result.x = math.max(result.x, result.x + min.x)
            result.y = result.y + min.y
        else -- Grid:
            result.x = math.max(result.x, result.x + min.x)
            result.y = math.max(result.y, result.y + min.y)
        end
    end

    if self.type == "HBox" or self.type == "Grid" then
        result.x = result.x + self.m_spacing * (#self.childs - 1)
    end

    if self.type == "VBox" or self.type == "Grid" then
        result.y = result.y + self.m_spacing * (#self.childs - 1)
    end

    return result
end