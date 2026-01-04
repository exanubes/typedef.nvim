local json_driver = require("typedef.drivers.json")
local json_encoder = require("typedef.infrastructure.encoder")

local Rpc = require("typedef.infrastructure.rpc")
local Server = require("typedef.infrastructure.server")

local M = {}

---@param config TypedefConfig
function M.register(config)
    local rpc = Rpc.new(config.rpc_server_binary)
    local server = Server.new(rpc, json_encoder)
    json_driver.register(server)
end

return M
