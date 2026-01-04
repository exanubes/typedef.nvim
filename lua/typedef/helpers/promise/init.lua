---@class Promise
---@field resolve fun(self: Promise, result: any)
---@field reject fun(self: Promise, result: any)
---@field on_success fun(self: Promise, fn: fun(result: any): any): Promise
---@field on_error fun(self: Promise, fn: fun(result: any): any): Promise
local Promise = {}
Promise.__index = Promise

function Promise.new()
    return setmetatable({
        done = false,
        result = nil,
        error = nil,
        success_handlers = {},
        error_handlers = {},
    }, Promise)
end

function Promise:resolve(result)
    if self.done then
        return
    end

    self.done = true
    self.result = result

    for _, fn in ipairs(self.success_handlers) do
        vim.schedule(function()
            fn(result)
        end)
    end
end

function Promise:reject(err)
    if self.done then
        return
    end

    self.done = true
    self.error = err

    for _, fn in ipairs(self.error_handlers) do
        vim.schedule(function()
            fn(err)
        end)
    end
end

function Promise:on_success(fn)
    if self.done and not self.error then
        vim.schedule(function()
            fn(self.result)
        end)
    else
        table.insert(self.success_handlers, fn)
    end

    return self
end

function Promise:on_error(fn)
    if self.done and self.error then
        vim.schedule(function()
            fn(self.error)
        end)
    else
        table.insert(self.error_handlers, fn)
    end

    return self
end

return Promise
