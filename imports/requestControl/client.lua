--- Request network control of an entity
---@param entity number
---@param timeout number? Miliseconds to wait for control
---@return boolean NetworkHasControlOfEntity
function lib.requestControl(entity, timeout)
    if not NetworkGetEntityIsNetworked(entity) or NetworkHasControlOfEntity(entity) then return true end
    
    if type(entity) ~= 'number' then
        error(("expected entity to have type 'number' (received %s)"):format(type(animDict)))
    end

    if not timeout or type(timeout) ~= 'number' then
        timeout = 5000
    end

    NetworkRequestControlOfEntity(entity)
    while not NetworkHasControlOfEntity(entity) and timeout > 0 do
        timeout -= 100
        Wait(100)
        NetworkRequestControlOfEntity(entity)
    end
    return NetworkHasControlOfEntity(entity)
end

return lib.requestControl