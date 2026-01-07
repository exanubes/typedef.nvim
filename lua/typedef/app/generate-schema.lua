local GenerateSchemaService = {
    --- @type InputReader
    input = nil,
    --- @type CodegenRepository
    codegen = nil,
    ---@type OutputWriter
    writer = nil,
}
GenerateSchemaService.__index = GenerateSchemaService

function GenerateSchemaService.new(reader, repository, writer)
    return setmetatable({
        input = reader,
        codegen = repository,
        output = writer,
    }, GenerateSchemaService)
end

---@param format string
function GenerateSchemaService:generate(format, cb)
    local input = self.input:read()
    local response = self.codegen:generate(input, "json", format)

    response:on_success(function(result)
        self.output:write(result.code)
        if cb then
            cb()
        end
    end)

    response:on_error(function(error)
        vim.notify("ERROR(" .. error.code .. "): " .. error.message)
    end)
end

return GenerateSchemaService
