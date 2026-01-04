local YankReader = {}
YankReader.__index = YankReader

function YankReader.new()
    return setmetatable({}, YankReader)
end

function YankReader:read()
    -- TODO: handle different yank registries
    -- NOTE: system clipboard
    return vim.fn.getreg("+", 1)
end

return YankReader
