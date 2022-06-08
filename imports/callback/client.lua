local events = {}
local timers = {}
local cbEvent = ('__cb_%s'):format(cache.resource)

RegisterNetEvent(cbEvent, function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

---@param event string
---@param delay number prevent the event from being called for the given time
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
---@param delay number
---@param cb function
---@param ... unknown
---@return unknown
local function triggerServerCallback(_, event, delay, cb, ...)
	if not eventTimer(event, delay) then return end

	local key

	repeat
		key = ('%s:%s'):format(event, math.random(0, 100000))
	until not events[key]

	TriggerServerEvent(('__cb_%s'):format(event), key, ...)

	local promise = not cb and promise.new()

	events[key] = function(response)
		events[key] = nil

		if promise then
			return promise:resolve(response)
		end

		cb(table.unpack(response))
	end

	if promise then
		return table.unpack(Citizen.Await(promise))
	end
end

---@overload fun(event: string, delay: number, cb: function, ...)
local callback = setmetatable({}, {
	__call = triggerServerCallback
})

---@param event string
---@param delay number prevent the event from being called for the given time
--- Sends an event to the server and halts the current thread until a response is returned.
function callback.await(event, delay, ...)
	return triggerServerCallback(_, event, delay, false, ...)
end

return callback
