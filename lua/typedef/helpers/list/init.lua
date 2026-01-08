local List = {}
--- @param source_table table<string>
--- @param new_items table<string>
--- @param position? integer exact position in the source_table where the first element from the new_items table should be placed
--- @return table<string>
function List.splice(source_table, new_items, position)
    if position == nil then
        position = #source_table
    end

    assert(position >= 1 and position <= #source_table + 1, "position out of bounds")

    local insert_length = #new_items

    for index = #source_table, position, -1 do
        source_table[index + insert_length] = source_table[index]
    end

    for index = 1, insert_length do
        source_table[position + index - 1] = new_items[index]
    end

    return source_table
end

--- @param ... table<string>[]
--- @return table<string>
function List.join(...)
    local result = {}
    for _, list in ipairs({ ... }) do
        for _, value in ipairs(list) do
            table.insert(result, value)
        end
    end
    return result
end

--- @param input string
--- @param separator string
function List.split(input, separator)
    separator = separator or "\\n"
    local t = {}
    for str in string.gmatch(input, "([^" .. separator .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return List
