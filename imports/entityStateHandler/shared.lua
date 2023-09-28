---@generic T
---@param keyFilter T
---@param bagFilter? string
---@param cb fun(keyName: T, entity: number, value: any, bagName: string)
---@param requireValue? boolean Require a value to run the state handler.
---@param setAsNil? boolean Set the statebag to nil once it has completed.
---@return number
function lib.entityStateHandler(keyFilter, bagFilter, cb, requireValue, setAsNil)
    return AddStateBagChangeHandler(keyFilter, bagFilter or '', function(bagName, keyName, value, reserved, replicated)
        if requireValue and not value then return end

        local entity = GetEntityFromStateBagName(bagName)

        if entity == 0 then
            return error(('%s received invalid entity! (%s)'):format(keyName, bagName))
        end

        if entity then
            cb(keyName, entity, value, bagName)

            if setAsNil then
                Wait(0)
                Entity(entity).state:set(keyName, nil, true)
            end
        end
    end)
end

return lib.entityStateHandler