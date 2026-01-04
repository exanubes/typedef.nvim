local generate_id = (function()
    local id = 0
    return function()
        id = id + 1
        return id
    end
end)()

local M = {}

--- @param method string
--- @param params table
M.create_rpc_request = function(method, params)
    return {
        jsonrpc = "2.0",
        id = generate_id(),
        method = method,
        params = params,
    }
end

--- @param input table?
--- @return boolean
M.validate = function(input)
    return (input and input.jsonrpc == "2.0" and input.id ~= nil) and true or false
end

return M
