---@class Component
local Form = {
    buffer = -1,
    window_id = -1,
    --- @type View
    view = nil,
}
Form.__index = Form

local function create_buffer()
    local buf = vim.api.nvim_create_buf(false, true)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].filetype = "typedef_panel"

    return buf
end

---@param view View
---@return Component
function Form.new(view)
    local buffer = create_buffer()
    return setmetatable({
        buffer = buffer,
        current_window = -1,
        view = view,
    }, Form)
end

function Form:open()
    if not vim.api.nvim_win_is_valid(self.window_id) then
        self.window_id = self.view.open(self.buffer)
    end
end

function Form:render(lines)
    vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, lines)
end

function Form:add_keymap(key, callback)
    vim.api.nvim_buf_set_keymap(self.buffer, "n", key, "", {
        nowait = true,
        noremap = true,
        silent = true,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(self.window_id)
            callback({
                key = key,
                buffer = self.buffer,
                window = self.window_id,
                current_line = cursor[1],
            })
        end,
    })
end

function Form:focus()
    self:open()
    self.view.focus(self.window_id)
end

function Form:close()
    self.view.close(self.window_id)
    self.window_id = -1
end

return Form
