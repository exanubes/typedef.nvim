local Rpc = {}
local Connection = {
    ---@type uv.uv_process_t
    server_handle = nil,
    ---@type uv.uv_pipe_t
    stdin_pipe = nil,
}

Connection.__index = Connection
Rpc.__index = Rpc

function Connection.new(server_handle, stdin_pipe)
    return setmetatable({
        server_handle = server_handle,
        stdin_pipe = stdin_pipe,
        active = true,
    }, Connection)
end

function Connection:close()
    if self.server_handle then
        self.server_handle:kill("sigterm")
        self.server_handle = nil
    end

    if self.stdin_pipe then
        self.stdin_pipe:close()
        self.stdin_pipe = nil
    end

    self.active = false
end

function Connection:is_active()
    return self.active
end

function Connection:send(message)
    self.stdin_pipe:write(message)
end

--- @return Rpc
function Rpc.new(binary_path)
    return setmetatable({ binary_path = binary_path }, Rpc)
end

function Rpc:connect(message_handler)
    local stdin = vim.uv.new_pipe()
    local stdout = vim.uv.new_pipe()
    local stderr = vim.uv.new_pipe()
    local connection
    local handle, process_id = vim.uv.spawn(self.binary_path, {
        args = {},
        stdio = { stdin, stdout, stderr },
    }, function(code, signal)
        -- NOTE: runs on exit
        -- TODO: add logs
        if connection then
            connection:close()
        end
    end)

    if not handle then
        return nil
    end

    connection = Connection.new(handle, stdin)

    stdout:read_start(function(err, data)
        if err then
            -- TODO: add logs
            return
        end

        if data then
            message_handler(data)
        end
    end)

    stderr:read_start(function(err, data)
        if err then
            -- TODO: add logs
            return
        end
        if data then
            message_handler(data)
            -- TODO: add logs
        end
    end)

    return connection
end

return Rpc
