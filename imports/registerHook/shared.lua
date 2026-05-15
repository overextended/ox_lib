--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class EventHook : OxClass
---@field private handler EventHandler
---@field private new EventHookConstructor
local EventHook = lib.class('EventHook')

---@class EventHookConstructor
---@overload fun(self: EventHook, hookId: string, resource: string, event: string): EventHook
---@private
---Creates a new EventHook instance bound to a specific exported hook.
function EventHook:constructor(hookId, resource, event)
    self.hookId = hookId
    self.resource = resource
    self.event = event
end

---@param handler fun(ok: boolean, payload: unknown)
---Attaches a post-execution event handler for this hook.
---The handler is triggered after the hooked event completes and receives:
---- `ok` whether the original event execution succeeded
---- `payload` the returned or processed event data
---
---If a handler is already registered, it will be replaced.
function EventHook:on(handler)
    self:off()
    self.handler = AddEventHandler(self.hookId, handler)
end

---Detaches the currently registered post-hook event handler, if one exists.
function EventHook:off()
    if self.handler then
        RemoveEventHandler(self.handler)
        self.handler = nil
    end
end

---Fully removes this hook from both the local event system and the external
---hook registry provided by the originating resource.
---
---This invalidates the hook instance; it should not be used afterward.
function EventHook:remove()
    self:off()
    exports[self.resource][('removeHook:%s'):format(self.event)](nil, self.hookId)
end

---@param eventName string An event identifier in the format of `resourceName:eventName`.
---@param handler? table|fun(payload: unknown): boolean A handler that is executed during the hook pipeline.
---@param options? table Options for the hook which can be used for filtering.
---@return EventHook
---Registers a new hook in the specified resource’s hook pipeline.
---
---@see HookPipeline
function lib.registerHook(eventName, handler, options)
    local resource, event = string.strsplit(':', eventName, 2)

    if not resource or not event then
        error(('Invalid event format: %s (expected "resourceName:eventName")'):format(event))
    end

    if type(handler) == 'table' and not options then
        options = handler
        handler = nil
    end

    local hookId = exports[resource][('registerHook:%s'):format(event)](nil, handler, options)

    return EventHook:new(hookId, resource, event)
end

return lib.registerHook
