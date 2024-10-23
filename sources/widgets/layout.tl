require("widget")
require("oop")
require("margin")

global enum LayoutType
    "HBox" "VBox" "Grid"
end

global record Layout is IWidget
    type: LayoutType
    margin: Margin
    spacing: number

    is_debug: boolean
    debug_color: Color
end

function Layout:new(parent: IWidget, align_type: LayoutType, size_policy?: Policy, size?: Vector2): Layout
    local self = extends(Layout, "Layout", Widget, parent, size_policy or Policy:new("Maximum"), size)

    if self.parent and type(self.parent) ~= "Layout" then
        self.parent:setLayout(self)
    end

    self.type = align_type
    self.margin = Margin:new(9, 9, 9, 9)
    self.spacing = 6

    self.is_debug = false
    self.debug_color = CachedColor:new(cmath.rand_int(150, 255), cmath.rand_int(20, 100), cmath.rand_int(20, 100), 100)

    return self
end

function Layout:addItem(item: IWidget)
    if not item then
        error("Layout: Cannot add a nil item")
    end

    self:addChild(item)
end

-- private:
function Layout:warp(child: IWidget)
    -- contract:
    if child.size_policy.h ~= "Fixed" then
        local right_edge = self.pos.x + self.size.x - self.margin.right

        if (child.pos.x + child.size.x) >= right_edge then
            child.size.x = child.size.x - (child.pos.x + child.size.x - right_edge)
        end
    end

    if child.size_policy.v ~= "Fixed" then
        local bottom_edge = self.pos.y + self.size.y - self.margin.bottom

        if (child.pos.y + child.size.y) >= bottom_edge then
            child.size.y = child.size.y - (child.pos.y + child.size.y - bottom_edge)
        end
    end
end

-- private:
function Layout:hAlign()
    local total_width = self.size.x - self.margin.left - self.margin.right
    local total_height = self.size.y - self.margin.top - self.margin.bottom
    
    local fixed_width: number = 0
    local warp_count = 0

    for _, child in ipairs(self.childs) do
        if child.size_policy.h ~= "Fixed" then
            warp_count = warp_count + 1
        else
            fixed_width = fixed_width + child.size.x
        end
    end

    local flexible_width = total_width - fixed_width
    local total_children_width: number = 0
    local max_children_count = 0

    for _, child in ipairs(self.childs) do
        if warp_count > 0 then
            local new_width = flexible_width / warp_count
            
            if child.size_policy.h == "Maximum" then
                child.size.x = math.max(child.min_size.x, new_width)
                max_children_count = max_children_count + 1
            elseif child.size_policy.h == "Minimum" then
                child.size.x = math.min(child.min_size.x, new_width)
            end
        end
        
        if child.size_policy.v == "Maximum" then
            child.size.y = total_height
        elseif child.size_policy.v == "Minimum" then
            child.size.y = math.min(child.min_size.y, total_height)
        end

        if child.size_policy.h ~= "Maximum" then
            total_children_width = total_children_width + child.size.x
        end
    end

    if max_children_count > 0 then
        local remaining_width = total_width - total_children_width - (max_children_count - 1) * self.spacing
        local new_width = remaining_width / max_children_count

        for _, child in ipairs(self.childs) do
            if child.size_policy.h == "Maximum" then
                child.size.x = new_width
                total_children_width = total_children_width + child.size.x
            end
        end
    end

    local offset = (total_width - total_children_width - (warp_count - 1) * self.spacing) / 2
    local current_x = self.pos.x + self.margin.left + math.max(0, offset)

    for i, child in ipairs(self.childs) do
        child.pos.x = current_x
        child.pos.y = self.pos.y + self.margin.top + (total_height - child.size.y) / 2

        current_x = current_x + child.size.x
        if i < #self.childs then
            current_x = current_x + self.spacing
        end
    end
end

-- private:
function Layout:vAlign()
    local total_width = self.size.x - self.margin.left - self.margin.right
    local total_height = self.size.y - self.margin.top - self.margin.bottom
    
    local fixed_height: number = 0
    local warp_count = 0

    for _, child in ipairs(self.childs) do
        if child.size_policy.v ~= "Fixed" then
            warp_count = warp_count + 1
        else
            fixed_height = fixed_height + child.size.y
        end
    end

    local flexible_height = total_height - fixed_height
    local total_children_height: number = 0
    local max_children_count = 0

    for _, child in ipairs(self.childs) do
        if warp_count > 0 then
            local new_height = flexible_height / warp_count
            
            if child.size_policy.v == "Maximum" then
                child.size.y = math.max(child.min_size.y, new_height)
                max_children_count = max_children_count + 1
            elseif child.size_policy.v == "Minimum" then
                child.size.y = math.min(child.min_size.y, new_height)
            end
        end
        
        if child.size_policy.h == "Maximum" then
                child.size.x = total_width
        elseif child.size_policy.h == "Minimum" then
            child.size.x = math.min(child.min_size.x, total_width)
        end

        if child.size_policy.v ~= "Maximum" then
            total_children_height = total_children_height + child.size.y
        end
    end

    if max_children_count > 0 then
        local remaining_height = total_height - total_children_height - (max_children_count - 1) * self.spacing
        local new_height = remaining_height / max_children_count

        for _, child in ipairs(self.childs) do
            if child.size_policy.v == "Maximum" then
                child.size.y = new_height
                total_children_height = total_children_height + child.size.y
            end
        end
    end

    local offset = (total_height - total_children_height - (warp_count - 1) * self.spacing) / 2
    local current_y = self.pos.y + self.margin.top + math.max(0, offset)

    for i, child in ipairs(self.childs) do
        child.pos.y = current_y
        child.pos.x = self.pos.x + self.margin.left + (total_width - child.size.x) / 2

        current_y = current_y + child.size.y
        if i < #self.childs then
            current_y = current_y + self.spacing
        end
    end
end

function Layout:setSpacing(spacing: number)
    self.spacing = spacing
end

function Layout:turnDebug(is_debug?: boolean)
    self.is_debug = is_debug == nil and true or is_debug
end

function Layout:getMargin(): Margin
    return self.margin:copy()
end

function Layout:setMargin(margin: Margin)
    self.margin = margin:copy()
end

-- override:
function Layout:update()
    if self.type == "HBox" then self:hAlign() end
    if self.type == "VBox" then self:vAlign() end
    if self.type == "Grid" then error("not impl") end

    for _, child in ipairs(self.childs) do
        self:warp(child)
        child:update()
    end
end

-- override
function Layout:render()
    if not self.is_visible then return end

    if self.is_debug then
        render.rectangle(self.pos.x, self.pos.y, self.size.x, self.size.y, self.debug_color)
    end

    self:childsRender()
end