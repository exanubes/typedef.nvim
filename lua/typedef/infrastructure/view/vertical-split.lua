---@class View
local VerticalSplitView = {}

---@param buffer integer
function VerticalSplitView.open(buffer)
    vim.cmd("vsplit")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buffer)

    vim.wo[win].winfixwidth = true
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].cursorline = true

    return win
end

function VerticalSplitView.focus(win)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
    end
end

function VerticalSplitView.close(win)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, false)
    end
end

return VerticalSplitView
