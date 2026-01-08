local Map = require("typedef.helpers.map")

---@class Signal
---@field value any
---@field subscriptions Map
---@field get fun(self: Signal): any
---@field set fun(self: Signal, new_state: any)
---@field subscribe fun(self: Signal, subscriber: fun(current: any)): fun()
local Signal = {}
Signal.__index = Signal

---@return Signal
function Signal.new(initial_state)
    return setmetatable({
        value = initial_state,
        subscriptions = Map.new(),
        count = 0,
    }, Signal)
end

function Signal:get()
    return self.value
end

function Signal:set(new_state)
    if self.value ~= new_state then
        self.value = new_state
        for _, fn in ipairs(self.subscriptions:values()) do
            fn(new_state)
        end
    end
end

function Signal:subscribe(fn)
    local subscription_id = self.count
    self.subscriptions:set(subscription_id, fn)
    self.count = subscription_id + 1

    fn(self.value)

    return function()
        self.subscriptions:remove(subscription_id)
    end
end

return Signal
