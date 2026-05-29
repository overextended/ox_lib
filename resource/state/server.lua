---@class StateHookOptions
---@field key string

---@class StateHookPayload
---@field playerId number
---@field targetId number
---@field entityId number
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
    local targetId = tonumber(target, 10)
    local pipeline = (targetType == 'entity' and setEntityState) or (targetType == 'player' and setPlayerState)

    if not pipeline or (targetType == 'player' and targetId ~= playerId) or #pipeline.hooks == 0 then
        return false
    end

    local hook <close> = pipeline:dispatch({
        playerId = playerId,
        targetId = targetId,
        entityId = NetworkGetEntityFromNetworkId(targetId),
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

---@param payload StateHookPayload
---@return boolean
setEntityState:registerHook(function(payload)
    if payload.value then return false end

    local vehicle = lib.vehicle:new(payload.entityId)
    local props = vehicle:get(payload.key) ---@type VehicleProperties?

    if not props then return false end

    if props.plate and props.plate:strtrim() ~= vehicle:getPlate():strtrim() then return false end

    -- we pray
    return true
end, { key = 'ox_lib:setVehicleProperties' })


---@param payload StateHookPayload
setEntityState:registerHook(function(payload)
    return payload.value == true or not payload.value
end, { key = 'ox_entity_setonground'})
