local ReplaceSelectionWriter = {}
ReplaceSelectionWriter.__index = ReplaceSelectionWriter

local visual_block_mode = "\22" --- ctrl+v

---@param with_range boolean
---@return OutputWriter
function ReplaceSelectionWriter.new(with_range)
    return setmetatable({ with_range = with_range }, ReplaceSelectionWriter)
end

function ReplaceSelectionWriter:write(input)
    local buf = vim.api.nvim_get_current_buf()
    local mode = vim.fn.mode()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local position = {
        start_col = col,
        start_row = math.max(row - 1, 0),
        end_col = col,
        end_row = math.max(row - 1, 0),
    }

    if self.with_range or mode == "v" or mode == "V" or mode == visual_block_mode then
        --- NOTE: same issue as with selection reader. To reliably retrieve selected buffer
        --- vim.api.nvim_buf_get_mark(buf, "[" | "]")
        --- The '< '> markers do not work when using motions e.g., %
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        position.start_col = math.max(start_pos[3] - 1, 0)
        position.start_row = math.max(start_pos[2] - 1, 0)
        position.end_col = math.max(end_pos[3] - 1, 0)
        position.end_row = math.max(end_pos[2] - 1, 0)
    end

    local lines = vim.split(input, "\n", {})

    vim.api.nvim_buf_set_text(buf, position.start_row, position.start_col, position.end_row, position.end_col, lines)
end

return ReplaceSelectionWriter
