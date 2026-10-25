--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local pendingCallbacks = {}
local cbEvent = '__ox_cb_%s'
local callbackTimeout = GetConvarInt('ox:callbackTimeout', 300000)

RegisterNetEvent(cbEvent:format(cache.resource), function(key, ...)
    local entry = pendingCallbacks[key]

    if not entry then return end

    if entry.playerId ~= source then
        return warn(("Player %d triggered callback event with invalid key '%s'."):format(source, key))
    end

    pendingCallbacks[key] = nil

    entry.resolve(...)
end)

AddEventHandler('playerDropped', function()
    local playerId = source

    for _, entry in pairs(pendingCallbacks) do
        if entry.playerId == playerId then
            entry.reject(("player %d dropped before responding to callback '%s'"):format(playerId, entry.event))
        end
    end
end)

---@param _ any
---@param event string
---@param playerId number
---@param cb function|false
---@param ... any
---@return ...
local function triggerClientCallback(_, event, playerId, cb, ...)
    assert(DoesPlayerExist(playerId --[[@as string]]), ("target playerId '%s' does not exist"):format(playerId))

    local key

    repeat
        key = ('%s:%s:%s'):format(event, math.random(0, 100000), playerId)
    until not pendingCallbacks[key]

    ---@type promise | false
    local promise = not cb and promise.new()
    local entry

    entry = {
        event = event,
        playerId = tonumber(playerId),
        resolve = function(response, ...)
            if response == 'cb_invalid' then
                response = ("callback '%s' does not exist"):format(event)

                return promise and promise:reject(response) or error(response)
            end

            response = { response, ... }

            if promise then
                return promise:resolve(response)
            end

            if cb then
                cb(table.unpack(response))
            end
        end,
        reject = function(reason)
            if pendingCallbacks[key] ~= entry then return end

            pendingCallbacks[key] = nil

            if promise then
                promise:reject(reason)
            end
        end
    }

    pendingCallbacks[key] = entry

    TriggerClientEvent('ox_lib:validateCallback', playerId, event, cache.resource, key)
    TriggerClientEvent(cbEvent:format(event), playerId, cache.resource, key, ...)

    SetTimeout(callbackTimeout, function()
        entry.reject(("callback event '%s' timed out"):format(key))
    end)

    if promise then
        return table.unpack(Citizen.Await(promise))
    end
end

---@overload fun(event: string, playerId: number, cb: function, ...)
lib.callback = setmetatable({}, {
    __call = function(_, event, playerId, cb, ...)
        if not cb then
            warn(("callback event '%s' does not have a function to callback to and will instead await\nuse lib.callback.await or a regular event to remove this warning")
                :format(event))
        else
            local cbType = type(cb)

            if cbType == 'table' and getmetatable(cb)?.__call then
                cbType = 'function'
            end

            assert(cbType == 'function', ("expected argument 3 to have type 'function' (received %s)"):format(cbType))
        end

        return triggerClientCallback(_, event, playerId, cb, ...)
    end
})

---@param event string
---@param playerId number
--- Sends an event to a client and halts the current thread until a response is returned.
---@diagnostic disable-next-line: duplicate-set-field
function lib.callback.await(event, playerId, ...)
    return triggerClientCallback(nil, event, playerId, false, ...)
end

local function callbackResponse(success, result, ...)
    if not success then
        if result then
            return print(('^1SCRIPT ERROR: %s^0\n%s'):format(result,
                Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''))
        end

        return false
    end

    return result, ...
end

local pcall = pcall

---@param name string
---@param cb function
---Registers an event handler and callback function to respond to client requests.
---@diagnostic disable-next-line: duplicate-set-field
function lib.callback.register(name, cb)
    local event = cbEvent:format(name)

    lib.setValidCallback(name, true)

    RegisterNetEvent(event, function(resource, key, ...)
        TriggerClientEvent(cbEvent:format(resource), source, key, callbackResponse(pcall(cb, source, ...)))
    end)
end

return lib.callback
