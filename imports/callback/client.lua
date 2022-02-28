local ServerCallbacks = {}

---@param event string
---@param delay number prevent the event from being called for the given time
local function callbackTimer(event, delay)
	if type(delay) == 'number' then
		local time = GetGameTimer()
		if (ServerCallbacks[event] or 0) > time then
			return false
		end
		ServerCallbacks[event] = time + delay
	end
	return true
end

local function startCallback(resource, event, ...)
	local id = math.random(0, 100000)
	event = ('__cb_%s:%s'):format(resource, event)
	TriggerServerEvent(event, id, ...)
	return event..id
end

local ServerCallback = table.create(0, 2)

---@param resource string
---@param event string
---@param delay number prevent the event from being called for the given time
--- Sends an event to the server and halts the current thread until a response is returned.
ServerCallback.Await = function(resource, event, delay, ...)
	if callbackTimer(event, delay) then
		local promise = promise.new()
		event = RegisterNetEvent(startCallback(resource, event, ...), function(response)
			promise:resolve(response)
			RemoveEventHandler(event)
		end)
		return table.unpack(Citizen.Await(promise))
	end
end

---@param resource string
---@param event string
---@param delay number
---@param cb function
--- Sends an event to the server and triggers a callback function once the response is returned.
ServerCallback.Async = function(resource, event, delay, cb, ...)
	if callbackTimer(event, delay) then
		event = RegisterNetEvent(startCallback(resource, event, ...), function(response)
			cb(table.unpack(response))
			RemoveEventHandler(event)
		end)
	end
end

return ServerCallback
