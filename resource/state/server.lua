---@class StateHookOptions
---@field key string

---@class StateHookPayload
---@field playerId number
---@field targetId number
---@field type 'entity' | 'player'
---@field bag string
---@field key string
---@field value unknown

---@param hook StateHookOptions
---@param payload StateHookPayload
local function filter(hook, payload)
    if hook.key and payload.key ~= hook.key then return false end

    return true
end

local setPlayerState = lib.hook:new('setPlayerState', filter)
local setEntityState = lib.hook:new('setEntityState', filter)

---@param playerId number
---@param bag string
---@param key string
---@param value unknown
---@param mode StateBagReplication
---@return boolean
lib.callback.register('ox_lib:requestSetStateBag', function(playerId, bag, key, value, mode)
    local targetType, target = string.strsplit(':', bag, 2)
    local targetId = tonumber(target)

    local pipeline = (targetType == 'entity' and setEntityState) or (targetType == 'player' and setPlayerState)

    if not pipeline or (targetType == 'player' and targetId ~= playerId) or #pipeline.hooks == 0 then
        return false
    end

    local hook <close> = pipeline:dispatch({
        playerId = playerId,
        targetId = target,
        type = targetType,
        bag = bag,
        key = key,
        value = value,
        mode = mode,
    })

    if not hook.ok or hook.size == 0 then return false end

    local packed = msgpack.pack(value)

    SetStateBagValue(bag, key, packed, #packed, mode == 1)

    return true
end)
