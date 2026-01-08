local GenerateSchemaService = {
    --- @type InputReader
    input = nil,
    --- @type CodegenRepository
    codegen = nil,
}
GenerateSchemaService.__index = GenerateSchemaService

function GenerateSchemaService.new(reader, repository)
    return setmetatable({
        input = reader,
        codegen = repository,
    }, GenerateSchemaService)
end

---@param format string
function GenerateSchemaService:generate(format, cb)
    local input = self.input:read()
    local response = self.codegen:generate(input, "json", format)

    response:on_success(function(result)
        if cb then
            cb()
        end
    end)

    response:on_error(function(error)
        vim.notify("ERROR(" .. error.code .. "): " .. error.message)
    end)
end

return GenerateSchemaService
