local Signal = require("Signal")
local Policy = require("Policy")
local Geometry = require("Geometry")

local interface IWidget
    m_parent: IWidget
    childs: { IWidget }
    m_layout: IWidget

    m_pos: Vector2
    is_visible: boolean
    is_active: boolean

    m_size: Vector2
    min_size: Vector2
    size_policy: Policy
    cursor_type: integer

    tooltip: string
    tooltip_duration: number
    is_tooltip_visible: boolean

-- public:
    parentWidget: function<Self>(Self): IWidget
    childAt: function<Self>(Self, integer): IWidget
    pos: function<Self>(Self): Vector2
    isVisible: function<Self>(Self): boolean
    isActive: function<Self>(Self): boolean
    size: function<Self>(Self): Vector2
    minSize: function<Self>(Self): Vector2 -- virtual
    geometry: function<Self>(Self): Geometry
    sizePolicy: function<Self>(Self): Policy
    cursor: function<Self>(Self): integer
    toolTip: function<Self>(Self): string

    setParent: function<Self>(Self, IWidget)
    addChild: function<Self>(Self, IWidget)
    setLayout: function<Self>(Self, IWidget) -- virtual
    setPos: function<Self>(Self, Vector2)
    bindPos: function<Self>(Self, Vector2) -- virtual
    setVisible: function<Self>(Self, boolean) -- virtual
    hide: function<Self>(Self)
    show: function<Self>(Self)
    setActive: function<Self>(Self, boolean) -- virtual
    disable: function<Self>(Self)
    enable: function<Self>(Self)
    minimize: function<Self>(Self)
    resize: function<Self>(Self, Vector2)
    bindSize: function<Self>(Self, Vector2) -- virtual
    setGeometry: function<Self>(Self, Geometry)
    setSizePolicy: function<Self>(Self, Policy)
    setCursor: function<Self>(Self, integer)
    resetCursor: function<Self>(Self)
    setToolTip: function<Self>(Self, string)

    isHover: function<Self>(Self): boolean
    peekFocus: function<Self>(Self)
    hasFocus: function<Self>(Self): boolean
    render: function<Self>(Self) -- virtual
    update: function<Self>(Self) -- virtual
    renderToolTip: function<Self>(Self) -- virtual
    childsRender: function<Self>(Self)
    childsUpdate: function<Self>(Self)

    sizeChanged: Signal
    posChanged: Signal
end

return IWidget