---@class GenerateService
---@field generate fun(self: GenerateService, format: string, cb: fun())

local Map = require("typedef.helpers.map")
local M = {
    formats = Map.new(),
}

M.formats:set("go", "golang")
M.formats:set("golang", "golang")
M.formats:set("jsdoc", "jsdoc")
M.formats:set("ts_zod", "zod")
M.formats:set("ts-zod", "zod")
M.formats:set("zod", "zod")
M.formats:set("typescript", "typescript")
M.formats:set("ts", "typescript")

---@param input string
---@return string | nil
function M.parse_format(input)
    input = string.lower(input)
    if M.formats:has(input) then
        return M.formats:get(input)
    end

    return nil
end

return M
