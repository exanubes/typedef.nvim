local ClipboardWriter = {}
ClipboardWriter.__index = ClipboardWriter

---@return OutputWriter
function ClipboardWriter.new()
    return setmetatable({}, ClipboardWriter)
end

function ClipboardWriter:write(input)
    vim.fn.setreg("+", input)
end

return ClipboardWriter
