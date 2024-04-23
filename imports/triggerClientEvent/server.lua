---Triggers an event for the given playerIds, sending additional parameters as arguments.\
---Implements functionality from [this pending pull request](https://github.com/citizenfx/fivem/pull/1210) and may be deprecated.
---
---Provides non-neglibible performance gains due to msgpacking all arguments _once_, instead of per-target.
---@param eventName string
---@param targetIds number | ArrayLike<number>
---@param ... any
function lib.triggerClientEvent(eventName, targetIds, ...)
    local payload = msgpack.pack_args(...)
    local payloadLen = #payload

    if lib.array.isArray(targetIds) then
        for i = 1, #targetIds do
            TriggerClientEventInternal(eventName, targetIds[i] --[[@as string]], payload, payloadLen)
        end

        return
    end

    TriggerClientEventInternal(eventName, targetIds --[[@as string]], payload, payloadLen)
end

return lib.triggerClientEvent
