local drivers = require("typedef.drivers")
local M = {}
local config = {
    rpc_server_binary = "",
}

---@param config TypedefConfig
function M.setup(config)
    drivers.register(config)
end

return M
