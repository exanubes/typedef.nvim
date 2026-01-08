local FormRenderer = require("typedef.app.form-renderer")
local YankReader = require("typedef.infrastructure.reader.yank")
local ChainReader = require("typedef.infrastructure.reader.chain")
local Codegen = require("typedef.infrastructure.codegen")
local BufferContextWriter = require("typedef.infrastructure.writer.buffer-context")
local ClipboardWriter = require("typedef.infrastructure.writer.clipboard")
local GenerateSchemaService = require("typedef.app.generate-schema")
local TypedefForm = require("typedef.infrastructure.form")

local M = {}

---@param server JsonRpcServer
---@param view View
function M.register(server, view)
    vim.api.nvim_create_user_command("TypedefPanel", function()
        server:start()

        local original_buffer = vim.api.nvim_get_current_buf()
        local original_window = vim.api.nvim_get_current_win()
        local typedef_form = TypedefForm.new(view)
        local input_reader = YankReader.new()
        local output_writer = ClipboardWriter.new()

        local codegen_repository = Codegen.new(server)

        local form_renderer = FormRenderer.new(typedef_form, codegen_repository, input_reader, output_writer)
        form_renderer:execute()
    end, {})
end

return M
