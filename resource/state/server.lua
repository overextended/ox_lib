---@param hook { type: string, key: string }
local setState = lib.hook:new('setState', function(hook, payload)
    if hook.type and not payload.type:match(hook.type) then return false end
    if hook.key and not payload.key:match(hook.key) then return false end

    return true
end)

---@param playerId number
---@param bag string
---@param key string
---@param value unknown
---@return boolean
lib.callback.register('ox_lib:requestSetStateBag', function(playerId, bag, key, value)
    local targetType, target = string.strsplit(':', bag, 2)
    local targetId = tonumber(target)

    if targetType ~= 'player' and targetType ~= 'entity' then return false end
    if targetType == 'player' and targetId ~= playerId then return false end

    if #setState.hooks == 0 then return false end

    local hook <close> = setState:dispatch({
        playerId = playerId,
        type = targetType,
        targetId = target,
        bag = bag,
        key = key,
        value = value,
    })

    if not hook.ok or hook.size == 0 then return false end

    local packed = msgpack.pack(value)

    SetStateBagValue(bag, key, packed, #packed, true)

    return true
end)
