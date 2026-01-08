local VerticalSplitView = require("typedef.infrastructure.view.vertical-split")
local SidebarOverlayView = require("typedef.infrastructure.view.side-panel-overlay")
local Factory = {}

---@param type "vsplit" | "sidebar"
---@return View
function Factory.create(type)
    type = type or ""

    if type == "vsplit" then
        return VerticalSplitView
    elseif type == "sidebar" then
        return SidebarOverlayView
    end

    return VerticalSplitView
end

return Factory
