local pendingCallbacks = {}
local timers = {}
local cbEvent = '__ox_cb_%s'
local callbackTimeout = GetConvarInt('ox:callbackTimeout', 300000)

RegisterNetEvent(cbEvent:format(cache.resource), function(key, ...)
    local cb = pendingCallbacks[key]
    pendingCallbacks[key] = nil

    return cb and cb(...)
end)

---@param event string
---@param delay? number | false prevent the event from being called for the given time
local function eventTimer(event, delay)
    if delay and type(delay) == 'number' and delay > 0 then
        local time = GetGameTimer()

        if (timers[event] or 0) > time then
            return false
        end

        timers[event] = time + delay
    end

    return true
end

---@param _ any
---@param event string
---@param delay number | false | nil
---@param cb function | false
---@param ... any
---@return ...
local function triggerServerCallback(_, event, delay, cb, bps, ...)
    if not eventTimer(event, delay) then return end

    local key

    repeat
        key = ('%s:%s'):format(event, math.random(0, 100000))
    until not pendingCallbacks[key]

    if bps then
        TriggerLatentServerEvent(cbEvent:format(event), bps, cache.resource, key, ...)
    else
        TriggerServerEvent(cbEvent:format(event), cache.resource, key, ...)
    end

    ---@type promise | false
    local promise = not cb and promise.new()

    pendingCallbacks[key] = function(response, ...)
        response = { response, ... }

        if promise then
            return promise:resolve(response)
        end

        if cb then
            cb(table.unpack(response))
        end
    end

    if promise then
        SetTimeout(callbackTimeout, function() promise:reject(("callback event '%s' timed out"):format(key)) end)

        return table.unpack(Citizen.Await(promise))
    end
end

---@overload fun(event: string, delay: number | false, cb: function, ...)
lib.callback = setmetatable({}, {
    __call = function(_, event, delay, cb, ...)
        if not cb then
            warn(("callback event '%s' does not have a function to callback to and will instead await\nuse lib.callback.await or a regular event to remove this warning")
                :format(event))
        else
            local cbType = type(cb)

            assert(cbType == 'function', ("expected argument 3 to have type 'function' (received %s)"):format(cbType))
        end

        return triggerServerCallback(_, event, delay, cb, nil, ...)
    end
})

---@param event string
---@param delay? number | false prevent the event from being called for the given time.
---Sends an event to the server and halts the current thread until a response is returned.
---@diagnostic disable-next-line: duplicate-set-field
function lib.callback.await(event, delay, ...)
    return triggerServerCallback(nil, event, delay, false, nil, ...)
end

---@param event string
---@param bps number
---@param cb function
---Works the same as lib.callback with this difference that this function sends latent client event
---@diagnostic disable-next-line: duplicate-set-field
function lib.callback.latent(event, bps, cb, ...)
    if not bps or type(bps) ~= 'number' then
        bps = 50000
    end

    return triggerServerCallback(nil, event, delay, cb, bps, ...)
end

---@param event string
---@param bps number
--- Sends an latent event to a client and halts the current thread until a response is returned.
---@diagnostic disable-next-line: duplicate-set-field
function lib.callback.latentAwait(event, bps, ...)
    if not bps or type(bps) ~= 'number' then
        bps = 50000
    end

    return triggerServerCallback(nil, event, delay, false, bps, ...)
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
---Registers an event handler and callback function to respond to server requests.
---@diagnostic disable-next-line: duplicate-set-field
function lib.callback.register(name, cb)
    RegisterNetEvent(cbEvent:format(name), function(resource, key, ...)
        TriggerServerEvent(cbEvent:format(resource), key, callbackResponse(pcall(cb, ...)))
    end)
end

---@param name string
---@param cb function
---@param bps number
---Works almost the same as lib.callback.register with the difference that this function sends latent server event
function lib.callback.registerLatent(name, bps, cb)
    if not bps or type(bps) ~= 'number' then
        bps = 50000
    end

    RegisterNetEvent(cbEvent:format(name), function(resource, key, ...)
        TriggerLatentServerEvent(cbEvent:format(resource), bps, key, callbackResponse(pcall(cb, ...)))
    end)
end

return lib.callback