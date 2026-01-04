---@class Map
---@field new fun(): Map
---@field set fun(self: Map, key: string, value: any)
---@field get fun(self: Map, key: string): any
---@field has fun(self: Map, key: string): boolean
---@field remove fun(self: Map, key: string)

local Map = {}
Map.__index = Map

function Map.new()
    return setmetatable({ _data = {} }, Map)
end

function Map:set(key, value)
    self._data[key] = value
end

function Map:get(key)
    return self._data[key]
end

function Map:has(key)
    return self._data[key] ~= nil
end

function Map:remove(key)
    self._data[key] = nil
end

return Map
