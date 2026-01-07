local Promise = require("typedef.helpers.promise")
local codegen = require("typedef.domain.codegen")

local Repository = {
    --- @type RpcClient
    client = nil,
}
Repository.__index = Repository

---@param rpc_client RpcClient
---@return CodegenRepository
function Repository.new(rpc_client)
    return setmetatable({ client = rpc_client }, Repository)
end

---@param input string
---@param input_type string
---@param format string
function Repository:generate(input, input_type, format)
    local response =
        self.client:send("codegen", { input = input, input_type = input_type, format = codegen.parse_format(format) })
    local result = Promise.new()

    response
        :on_success(function(data)
            --- TODO: validate response object
            result:resolve(data)
        end)
        :on_error(function(error)
            result:reject(error)
        end)

    return result
end

return Repository
