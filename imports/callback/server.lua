local events = {}
local cbEvent = ('__cb_%s'):format(cache.resource)

RegisterNetEvent(cbEvent, function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

---@param _ any
---@param event string
---@param playerId number
---@param cb function
---@param ... unknown
---@return unknown
local function triggerClientCallback(_, event, playerId, cb, ...)
	local key

	repeat
		key = ('%s:%s:%s'):format(event, math.random(0, 100000), playerId)
	until not events[key]

	TriggerClientEvent(('__cb_%s'):format(event), playerId, key, ...)

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

---@overload fun(event: string, playerId: number, cb: function, ...)
local callback = setmetatable({}, {
	__call = triggerClientCallback
})

---@param event string
---@param playerId number
--- Sends an event to a client and halts the current thread until a response is returned.
function callback.await(event, playerId, ...)
	return triggerClientCallback(_, event, playerId, false, ...)
end

---@param name string
---@param cb function
--- Registers an event handler and callback function to respond to client requests.
function callback.register(name, cb)
	name = ('__cb_%s'):format(name)

	RegisterNetEvent(name, function(key, ...)
		TriggerClientEvent(cbEvent, source, key, { cb(source, ...) })
	end)
end

return callback