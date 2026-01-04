local drivers = require("typedef.drivers")
local config = require("typedef.config")
local install = require("typedef.install")
local M = {}
local default_config = {
    rpc_server_binary = config.binary_path,
}

---@param config TypedefConfig
function M.setup(config)
    if not config.rpc_server_binary then
        install()
    end

    config.rpc_server_binary = config.rpc_server_binary or default_config.rpc_server_binary
    drivers.register(config)
end

return M
