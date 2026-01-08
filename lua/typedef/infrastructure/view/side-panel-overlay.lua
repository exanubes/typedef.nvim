---@class View
local SideOverlayView = {}

---@param buffer integer
function SideOverlayView.open(buffer)
    local win = vim.api.nvim_open_win(buffer, false, {
        relative = "editor",
        width = 40,
        height = vim.o.lines - 4,
        col = vim.o.columns - 42,
        row = 2,
        style = "minimal",
        border = "rounded",
    })

    vim.wo[win].cursorline = true

    return win
end

function SideOverlayView.focus(win)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
    end
end

function SideOverlayView.close(win)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, false)
    end
end

return SideOverlayView
