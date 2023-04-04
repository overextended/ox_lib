local events = {}
local timers = {}
local cbEvent = ('__ox_cb_%s')

RegisterNetEvent(cbEvent:format(cache.resource), function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

---@param event string
---@param delay number | false prevent the event from being called for the given time
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
---@param delay number | false
---@param cb function|false
---@param ... any
---@return ...
local function triggerServerCallback(_, event, delay, cb, ...)
	if not eventTimer(event, delay) then return end

	local key

	repeat
		key = ('%s:%s'):format(event, math.random(0, 100000))
	until not events[key]

	TriggerServerEvent(cbEvent:format(event), cache.resource, key, ...)

	---@type promise | false
	local promise = not cb and promise.new()

	events[key] = function(response, ...)
        response = { response, ... }
		events[key] = nil

		if promise then
			return promise:resolve(response)
		end

        if cb then
            cb(table.unpack(response))
        end
	end

	if promise then
		return table.unpack(Citizen.Await(promise))
	end
end

---@overload fun(event: string, delay: number | false, cb: function, ...)
lib.callback = setmetatable({}, {
	__call = triggerServerCallback
})

---@param event string
---@param delay number | false prevent the event from being called for the given time
--- Sends an event to the server and halts the current thread until a response is returned.
function lib.callback.await(event, delay, ...)
	return triggerServerCallback(nil, event, delay, false, ...)
end

local function callbackResponse(success, result, ...)
	if not success then
		if result then
			return print(('^1SCRIPT ERROR: %s^0\n%s'):format(result , Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''))
		end

		return false
	end

	return result, ...
end

local pcall = pcall

---@param name string
---@param cb function
--- Registers an event handler and callback function to respond to server requests.
function lib.callback.register(name, cb)
	RegisterNetEvent(cbEvent:format(name), function(resource, key, ...)
		TriggerServerEvent(cbEvent:format(resource), key, callbackResponse(pcall(cb, ...)))
	end)
end

return lib.callback
