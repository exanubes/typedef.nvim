local Buffer = require("typedef.helpers.buffer")
local Map = require("typedef.helpers.map")
local Promise = require("typedef.helpers.promise")
local utils = require("typedef.infrastructure.server.utils")

---@alias JsonRpcServer Server | RpcClient

local Server = {}
Server.__index = Server
local instance = nil
---@param rpc Rpc
---@param encoder Encoder
---@return JsonRpcServer
function Server.new(rpc, encoder)
    if instance then
        return instance
    end

    instance = setmetatable({
        running = false,
        encoder = encoder,
        pending_requests = Map.new(),
        response_buffer = Buffer.new(),
        connection = nil,
        rpc = rpc,
    }, Server)

    return instance
end

function Server:start()
    if self.running then
        return
    end

    self.connection = self.rpc:connect(function(data)
        self:handle(data)
    end)
end

--- @param data string
function Server:handle(data)
    self.response_buffer:append(data)

    while true do
        local line = self.response_buffer:read_line()

        if not line then
            break
        end

        if line:match("^%s*$") then
            goto continue
        end

        local ok, message = pcall(self.encoder.decode, line)

        if not ok then
            goto continue
        end

        if not utils.validate(message) then
            goto continue
        end

        local promise = self.pending_requests:get(message.id)

        if not promise then
            goto continue
        end

        self.pending_requests:remove(message.id)

        if message.error then
            promise:reject(message.error)
        else
            promise:resolve(message.result)
        end
        ::continue::
    end
end

function Server:send(method, payload)
    local promise = Promise.new()

    if not self.connection or not self.connection:is_active() then
        promise:reject({ message = "RPC server connection is closed" })
        return promise
    end

    local message = utils.create_rpc_request(method, payload)

    self.pending_requests:set(message.id, promise)

    local encoded_message = self.encoder.encode(message) .. "\n"

    self.connection:send(encoded_message)

    return promise
end

return Server
