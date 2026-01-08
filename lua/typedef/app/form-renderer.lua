local Map = require("typedef.helpers.map")
local Select = require("typedef.helpers.select")
local List = require("typedef.helpers.list")
local Signal = require("typedef.helpers.signal")

local EXIT_BUTTON = "[Exit]"
local GENERATE_BUTTON = "[Generate]"
local CLIPBOARD_BUTTON = "[Copy to clipboard]"

local function create_lines(options)
    local lines = {
        "Select input format",
        "(*) json",
        "",
        "Select output format",
        --- NOTE: Injected using splice()
        "",
        GENERATE_BUTTON,
        CLIPBOARD_BUTTON,
        EXIT_BUTTON,
        "",
        "================ OUTPUT ================",
        "",
    }
    return List.splice(lines, options, 5)
end

local M = {
    ---@type Component
    panel = nil,
    ---@type CodegenRepository
    codegen = nil,
    ---@type OutputWriter
    writer = nil,
    ---@type  InputReader
    reader = nil,
}

M.__index = M

---@param panel Component
---@param codegen CodegenRepository
---@param reader InputReader
---@param writer OutputWriter
function M.new(panel, codegen, reader, writer)
    return setmetatable({
        panel = panel,
        codegen = codegen,
        writer = writer,
        reader = reader,
    }, M)
end

function M:execute()
    local keymap = Map.new()
    keymap:set("1", 1)
    local format_options_offset = 4
    local format_options = Select.new({ "Go", "Typescript", "Zod", "JSDoc" })

    format_options:add_keymap("1", 1)
    format_options:add_keymap("2", 2)
    format_options:add_keymap("3", 3)
    format_options:add_keymap("4", 4)

    local lines = create_lines(format_options:print())
    local output = Signal.new("")

    local function handle_select(option_number)
        format_options:select(option_number)
        lines = create_lines(format_options:print())
        lines = List.join(lines, List.split(output:get(), "\n"))
        self.panel:render(lines)
    end

    self.panel:add_keymap("q", function()
        self.panel:close()
    end)

    self.panel:add_keymap("1", function()
        handle_select(1)
    end)

    self.panel:add_keymap("2", function()
        handle_select(2)
    end)

    self.panel:add_keymap("3", function()
        handle_select(3)
    end)

    self.panel:add_keymap("4", function()
        handle_select(4)
    end)

    self.panel:add_keymap("<CR>", function(event)
        if lines[event.current_line] == GENERATE_BUTTON then
            local format = format_options:selected()
            local input = self.reader:read()
            self.codegen
                :generate(input, "json", format)
                :on_success(function(response)
                    output:set(response.code)
                end)
                :on_error(function(error)
                    output:set(tostring(error.code) .. ": " .. error.message)
                end)
            return
        end

        if lines[event.current_line] == EXIT_BUTTON then
            self.panel:close()
            return
        end

        if lines[event.current_line] == CLIPBOARD_BUTTON then
            self.writer:write(output:get())
            return
        end

        handle_select(event.current_line - format_options_offset)
    end)

    output:subscribe(function(current)
        if current == "" then
            return
        end
        lines = create_lines(format_options:print())
        lines = List.join(lines, List.split(current, "\n"))
        self.panel:render(lines)
    end)

    self.panel:open()
    self.panel:focus()
    self.panel:render(lines)
end

return M
