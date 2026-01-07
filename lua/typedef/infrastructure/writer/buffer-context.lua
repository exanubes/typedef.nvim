local BufferContextWriter = {}
BufferContextWriter.__index = BufferContextWriter

---@param buffer integer
---@param window integer
---@param writer OutputWriter
---@return OutputWriter
function BufferContextWriter.new(buffer, window, writer)
    return setmetatable({
        buffer = buffer,
        window = window,
        writer = writer,
    }, BufferContextWriter)
end

function BufferContextWriter:write(input)
    vim.api.nvim_set_current_win(self.window)
    self.writer:write(input)
end

return BufferContextWriter
