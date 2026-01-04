local ChainReader = {}
ChainReader.__index = ChainReader

---@param readers InputReader[]
function ChainReader.new(readers)
    return setmetatable({ readers = readers }, ChainReader)
end

function ChainReader:read()
    for index, reader in ipairs(self.readers) do
        local result = reader:read()
        if result ~= "" then
            return result
        end
    end

    return ""
end

return ChainReader
