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

---@param payload unknown
---@return { ok: boolean, size: number }
---Executes the hook pipeline for the payload.
---
---Each registered hook is evaluated in order of registration, checking the payload against a provided filter\
---using the hook options and executing the hook callback.
---
---A hook may block execution by returning `false` from the pipeline filter or its own callback.
---
---If any hook rejects the execution, dispatch is cancelled and `result.ok` is set to `false`.
---
---The returned object acts as a finalisation handle and emits results to registered handlers once closed.
function lib.hook:dispatch(payload)
    local events = {};
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
