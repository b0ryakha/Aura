--TODO: write docs
--TODO: 'private' comment to real private methods
local aura = {
    fmt = require("fmt"),
    theme = require("theme"),
    cursors = require("cursors"),

    Align = require("Align"),
    UserInterface = require("UserInterface"),
    Policy = require("Policy"),
    Orientation = require("Orientation"),
    ModelItem = require("ModelItem"),
    ModelIndex = require("ModelIndex"),
    Model = require("Model"),
    IModel = require("IModel"),
    Margins = require("Margins"),
    ListModel = require("ListModel"),
    Geometry = require("Geometry"),
    DelegateOption = require("DelegateOption"),
    Delegate = require("Delegate"),
    IDelegate = require("IDelegate"),

    Application = require("Application"),
    CheckBox = require("CheckBox"),
    GroupBox = require("GroupBox"),
    Image = require("Image"),
    Label = require("Label"),
    Layout = require("Layout"),
    ListView = require("ListView"),
    ProgressBar = require("ProgressBar"),
    PushButton = require("PushButton"),
    Slider = require("Slider"),
    Spacer = require("Spacer"),
    Window = require("Window"),
    Widget = require("Widget"),
    IWidget = require("IWidget")
}

return aura