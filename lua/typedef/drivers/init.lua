local json_driver = require("typedef.drivers.json")
local panel_driver = require("typedef.drivers.panel")
local json_encoder = require("typedef.infrastructure.encoder")
local ViewFactory = require("typedef.infrastructure.view.factory")

local Rpc = require("typedef.infrastructure.rpc")
local Server = require("typedef.infrastructure.server")

local M = {}

---@param config TypedefConfig
function M.register(config)
    local rpc = Rpc.new(config.rpc_server_binary)
    local server = Server.new(rpc, json_encoder)
    local view = ViewFactory.create(config.view)
    json_driver.register(server)
    panel_driver.register(server, view)
end

return M
