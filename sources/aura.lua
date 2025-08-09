--TODO: write docs
package.path = package.path .. ";./sources/widgets/?.lua"

local aura = {
    fmt = require("fmt"),
    theme = require("theme"),

    Application = require("Application")--[[@as Application]],
    CheckBox = require("CheckBox")--[[@as CheckBox]],
    GroupBox = require("GroupBox")--[[@as GroupBox]],
    Image = require("Image")--[[@as Image]],
    Label = require("Label")--[[@as Label]],
    Layout = require("Layout")--[[@as Layout]],
    ListView = require("ListView")--[[@as ListView]],
    ProgressBar = require("ProgressBar")--[[@as ProgressBar]],
    PushButton = require("PushButton")--[[@as PushButton]],
    Slider = require("Slider")--[[@as Slider]],
    Spacer = require("Spacer")--[[@as Spacer]],
    Window = require("Window")--[[@as Window]],
    Widget = require("Widget")--[[@as Widget]],

    Signal = require("Signal")--[[@as Signal]],
    Align = require("Align")--[[@as Align]],
    Policy = require("Policy")--[[@as Policy]],
    Orientation = require("Orientation")--[[@as Orientation]],
    ModelItem = require("ModelItem")--[[@as ModelItem]],
    ModelIndex = require("ModelIndex")--[[@as ModelIndex]],
    Model = require("Model")--[[@as Model]],
    Margins = require("Margins")--[[@as Margins]],
    ListModel = require("ListModel")--[[@as ListModel]],
    Geometry = require("Geometry")--[[@as Geometry]],
    DelegateOption = require("DelegateOption")--[[@as DelegateOption]],
    Delegate = require("Delegate")--[[@as Delegate]],
    UserInterface = require("UserInterface")--[[@as UserInterface]]
}

return aura