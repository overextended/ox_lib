local registeredCallbacks = {}

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource == resourceName then return end

    for callbackName, resource in pairs(registeredCallbacks) do
        if resource == resourceName then
            registeredCallbacks[callbackName] = nil
        end
    end
end)

---For internal use only.
---Sets a callback event as registered to a specific resource, preventing it from
---being overwritten. Any unknown callbacks will return an error to the caller.
---@param callbackName string
---@param isValid boolean
function lib.setValidCallback(callbackName, isValid)
    local resourceName = GetInvokingResource() or cache.resource
    local callbackResource = registeredCallbacks[callbackName]

    if callbackResource then
        if not isValid then
            callbackResource[callbackName] = nil
            return
        end

        if callbackResource == resourceName then return end

        error(("cannot overwrite callback '%s' owned by resource '%s'"):format(callbackName, callbackResource))
    end

    lib.print.verbose(("set valid callback '%s' for resource '%s'"):format(callbackName, resourceName))

    registeredCallbacks[callbackName] = resourceName
end

function lib.isCallbackValid(callbackName)
    return registeredCallbacks[callbackName] == GetInvokingResource() or cache.resource
end

local cbEvent = '__ox_cb_%s'

RegisterNetEvent('ox_lib:validateCallback', function(callbackName, invokingResource, key)
    if registeredCallbacks[callbackName] then return end

    local event = cbEvent:format(invokingResource)

    if cache.game == 'fxserver' then
        return TriggerClientEvent(event, source, key, 'cb_invalid')
    end

    TriggerServerEvent(event, key, 'cb_invalid')
end)
