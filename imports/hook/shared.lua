--[[
https://github.com/overextended/ox_lib

This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

Copyright © 2025 Linden <https://github.com/thelindat>

]]

local hooks = {}

AddEventHandler('onResourceStop', function(resource)
    for i = 1, #hooks do
        hooks[i]:remove(resource)
    end
end)

---@class HookPipeline : OxClass
---@field private new HookPipelineConstructor

lib.hook = lib.class('HookPipeline')

---@class HookPipelineConstructor
---@overload fun(self: HookPipeline, event: string, filter: fun(hook: table, payload: unknown): boolean): HookPipeline
---@private

---Creates a hook pipeline for a specific event.
---
---The pipeline manages a collection of registered hooks and controls execution
---flow through filtering, rejection, and dispatching.
---
---It also exposes external resource hooks:
---- `registerHook:<event>` adds a hook to the pipeline
---- `removeHook:<event>` removes a hook from the pipeline
---
---@see EventHook

function lib.hook:constructor(event, filter)
    self.hooks = {}
    self.event = event
    self.filter = filter
    self._rateLimit = nil
    self._rateLimitState = {}

    hooks[#hooks + 1] = self

    exports(('registerHook:%s'):format(event), function(funcref, options)
        return self:registerHook(funcref, options)
    end)

    exports(('removeHook:%s'):format(event), function(hookId)
        local resource = GetInvokingResource() or cache.resource
        self:remove(resource, hookId)
    end)
end

---@param cb? fun(payload: unknown): boolean
---@param options? table Optional metadata attached to the hook.
---@return string
---Registers a hook into the pipeline for the current event.
function lib.hook:registerHook(cb, options)
    local idx = #self.hooks + 1
    local resource = GetInvokingResource()
    local hook = {}

    if options then
        for k, v in pairs(options) do
            hook[k] = v
        end
    end

    hook.cb = cb
    hook.resource = resource or cache.resource
    hook.hookId = ('%s:%s:%s'):format(hook.resource, self.event, idx)
    self.hooks[idx] = hook

    return hook.hookId
end

---@param resource string
---@param hookId? string
---Removes hooks from the pipeline.
---- If `hookId` is provided, only the matching hook is removed.
---- If omitted, all hooks belonging to the invoking resource are removed.
function lib.hook:remove(resource, hookId)
    for i = #self.hooks, 1, -1 do
        local hook = self.hooks[i]
        if hook.resource == resource and (not hookId or hook.hookId == hookId) then
            table.remove(self.hooks, i)
        end
    end
end

---@class RateLimitOptions
---@field maxCalls number Maximum number of calls allowed within the window.
---@field window number Time window in milliseconds.
---@field key? fun(payload: unknown): string Function to derive a tracking key from the payload (default: invoking player source).
---@field onExceeded? fun(key: string, payload: unknown) Optional callback invoked when the rate limit is exceeded (e.g. for logging or banning).

---Sets a rate limit for this pipeline.
---
---Every call to `dispatch` is tracked per key (default: player source).
---If the number of calls exceeds `maxCalls` within `window` ms, dispatch is
---cancelled immediately and `result.ok` is set to `false`.
---
---Example:
---```lua
---myPipeline:setRateLimit({ maxCalls = 5, window = 1000 })
---```
---
---@param options RateLimitOptions
function lib.hook:setRateLimit(options)
    assert(type(options) == 'table', 'options must be a table')
    assert(type(options.maxCalls) == 'number' and options.maxCalls > 0, 'maxCalls must be a positive number')
    assert(type(options.window) == 'number' and options.window > 0, 'window must be a positive number (ms)')

    self._rateLimit = options
    self._rateLimitState = {}
end

---Removes the rate limit from this pipeline.
function lib.hook:clearRateLimit()
    self._rateLimit = nil
    self._rateLimitState = {}
end

---@private
---Checks whether the current call is within the rate limit.
---Returns true if allowed, false if exceeded.
function lib.hook:_checkRateLimit(payload)
    local rl = self._rateLimit
    if not rl then return true end

    local key = rl.key and rl.key(payload) or tostring(source)
    local now = GetGameTimer()
    local state = self._rateLimitState[key]

    -- Window has expired or no prior call recorded — start a fresh window.
    if not state or (now - state.windowStart) >= rl.window then
        self._rateLimitState[key] = { count = 1, windowStart = now }
        return true
    end

    state.count += 1

    if state.count > rl.maxCalls then
        if rl.onExceeded then
            rl.onExceeded(key, payload)
        end
        return false
    end

    return true
end

---@param payload unknown
---@return { ok: boolean, size: number }
---Executes the hook pipeline for the payload.
---
---Each registered hook is evaluated in order of registration, checking the payload against a provided filter
---using the hook options and executing the hook callback.
---
---A hook may block execution by returning `false` from the pipeline filter or its own callback.
---
---If any hook rejects the execution, dispatch is cancelled and `result.ok` is set to `false`.
---
---If a rate limit is set and exceeded, dispatch is cancelled immediately before any hook runs.
---
---The returned object acts as a finalisation handle and emits results to registered handlers once closed.
function lib.hook:dispatch(payload)
    -- Rate limit is checked before any hook runs.
    if not self:_checkRateLimit(payload) then
        return { ok = false, size = 0 }
    end

    local events = {}

    local result = setmetatable({ ok = true, size = 0 }, {
        __close = function(result, err)
            if err then
                result.ok = false
            end

            local packed = msgpack.pack_args(result.ok, payload)
            local packedLength = #packed

            for i = 1, #events do
                TriggerEventInternal(events[i], packed, packedLength)
            end
        end
    })

    for i = 1, #self.hooks do
        local hook = self.hooks[i]
        local runHook = self.filter and self.filter(hook, payload) ~= false
        local rejected = runHook and hook.cb and hook.cb(payload) == false

        if rejected then
            result.ok = false
            break
        end

        if runHook then
            events[i] = hook.hookId
        end
    end

    result.size = #events
    return result
end

return lib.hook
