local InsertAtCursorWriter = {}
InsertAtCursorWriter.__index = InsertAtCursorWriter

---@return OutputWriter
function InsertAtCursorWriter.new()
    return setmetatable({}, InsertAtCursorWriter)
end

function InsertAtCursorWriter:write(input)
    local buf = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local line_len = vim.api.nvim_strwidth(line)

    row = math.max(row - 1, 0) --- NOTE: 0-based indexing, row-1 is last row
    col = col + 1 --- NOTE: after cursor

    if col > line_len then
        col = line_len
    end

    local lines = vim.split("\n" .. input, "\n", {})

    vim.api.nvim_buf_set_text(buf, row, col, row, col, lines)
end

return InsertAtCursorWriter
