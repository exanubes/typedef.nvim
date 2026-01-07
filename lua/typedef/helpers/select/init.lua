local Select = { options = {} }
Select.__index = Select

---@param options string[]
function Select.new(options)
    return setmetatable({
        options = options,
        current = 1,
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
            table.insert(lines, "( ) " .. option)
        end
    end

    return lines
end

return Select
