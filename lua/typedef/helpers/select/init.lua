local Map = require("typedef.helpers.map")
local Select = { options = {} }
Select.__index = Select

---@param options string[]
function Select.new(options)
    return setmetatable({
        options = options,
        current = 1,
        keymaps = Map.new(),
    }, Select)
end

--- @return string
function Select:selected()
    return self.options[self.current]
end

--- @param index integer
function Select:select(index)
    if not index then
        return
    end

    if index < 1 or index > #self.options then
        --- NOTE: outside the bounds
        return
    end

    self.current = index
end

--- @return string[]
function Select:print()
    local lines = {}

    for index, option in ipairs(self.options) do
        if index == self.current then
            table.insert(lines, "(*) " .. option)
        else
            local keymap = self.keymaps:get(index)
            local radio_button = ("(%s) "):format(keymap or " ")
            table.insert(lines, radio_button .. option)
        end
    end

    return lines
end

---@param keymap string
---@param index integer
function Select:add_keymap(keymap, index)
    self.keymaps:set(index, keymap)
end

return Select
