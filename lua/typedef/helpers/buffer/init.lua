---@class Buffer
---@field new fun(): Buffer
---@field size fun(self: Buffer): number
---@field append fun(self: Buffer, data: string)
---@field read_line fun(self: Buffer): string|nil
local Buffer = {}
Buffer.__index = Buffer

function Buffer.new()
    return setmetatable({ _data = "" }, Buffer)
end

function Buffer:size()
    return #self._data
end

function Buffer:append(data)
    self._data = self._data .. data
end

function Buffer:read_line()
    local newline_position = self._data:find("\n")

    if not newline_position then
        return nil
    end

    local json_line = self._data:sub(1, newline_position + 1)
    self._data = self._data:sub(newline_position + 1)

    return json_line
end

return Buffer
