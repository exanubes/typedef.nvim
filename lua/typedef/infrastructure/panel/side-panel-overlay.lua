---@param buffer integer
local function create_window(buffer)
    local win = vim.api.nvim_open_win(buffer, true, {
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

local function create_buffer()
    local buf = vim.api.nvim_create_buf(false, true)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "typedef_panel"

    return buf
end

local Panel = {
    buffer = -1,
    window = -1,
}
Panel.__index = Panel

function Panel.new()
    local buffer = create_buffer()
    return setmetatable({
        buffer = buffer,
        window = create_window(buffer),
    }, Panel)
end

function Panel:render(lines)
    if self.window < 0 then
        self.window = create_window(self.buffer)
    end

    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, lines)
end

function Panel:add_keymap(key, callback)
    vim.api.nvim_buf_set_keymap(self.buffer, "n", key, "", {
        nowait = true,
        noremap = true,
        silent = true,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(self.window)
            callback({
                key = key,
                buffer = self.buffer,
                window = self.window,
                current_line = cursor[1],
            })
        end,
    })
end

function Panel:close()
    vim.api.nvim_win_close(self.window, true)
    self.window = -1
end

return Panel
