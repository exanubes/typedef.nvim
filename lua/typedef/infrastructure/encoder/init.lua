---@type Encoder
local JsonEncoder = {
    error = nil,
}

function JsonEncoder.encode(data)
    local ok, result = pcall(vim.json.encode, data)

    if not ok then
        JsonEncoder.error("JSON encoding failed: " .. result)
    end

    return result
end

function JsonEncoder.decode(data)
    local ok, result = pcall(vim.json.decode, data)

    if not ok then
        JsonEncoder.error("JSON decoding failed: " .. result)
        return nil
    end

    return result
end

return JsonEncoder
