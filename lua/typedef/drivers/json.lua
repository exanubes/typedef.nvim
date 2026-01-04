local codegen = require("typedef.domain.codegen")
local Codegen = require("typedef.infrastructure.codegen")
local SelectionReader = require("typedef.infrastructure.reader.selection")
local YankReader = require("typedef.infrastructure.reader.yank")
local ChainReader = require("typedef.infrastructure.reader.chain")
local InsertWriter = require("typedef.infrastructure.writer.insert")
local M = {}

---@param server JsonRpcServer
function M.register(server)
    vim.api.nvim_create_user_command("TypedefJson", function(opts)
        local arg = opts.args
        local format = codegen.parse_format(arg)
        if not format then
            vim.notify("[TypedefJson] invalid format: " .. arg, vim.log.levels.ERROR)
            return
        end
        server:start()
        local with_range = opts.range > 0
        local input_reader = ChainReader.new({
            ---SelectionReader.new(with_range), --- NOTE: might have to create a custom operator to make selection reader reliable
            YankReader.new(),
        })
        local codegen_repository = Codegen.new(server)
        local input = input_reader:read()

        local response = codegen_repository:generate(input, "json", format)
        local output_writer = InsertWriter.new(with_range)
        response
            :on_success(function(data)
                output_writer:write(data.code)
            end)
            :on_error(function(err)
                vim.notify("error: " .. err.message)
            end)
    end, { nargs = 1, range = true })
end

return M
