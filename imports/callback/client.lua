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

local function triggerCallback(event, ...)
	local id = math.random(0, 100000)
	event = ('__cb_%s'):format(event)
	TriggerServerEvent(event, id, ...)
	return event..id
end

---Sends an event to the server and triggers a callback function once the response is returned.
---```
---callback(event: string, delay: number, function(...)
---	print(...)
---end)
---```
local callback = {}

---@param event string
---@param delay number prevent the event from being called for the given time
--- Sends an event to the server and halts the current thread until a response is returned.
function callback.await(event, delay, ...)
	if callbackTimer(event, delay) then
		local promise = promise.new()
		event = RegisterNetEvent(triggerCallback(event, ...), function(response)
			promise:resolve(response)
			RemoveEventHandler(event)
		end)
		return table.unpack(Citizen.Await(promise))
	end
end

return setmetatable(callback, {
	__call = function(self, event, delay, cb, ...)
		if callbackTimer(event, delay) then
			event = RegisterNetEvent(triggerCallback(event, ...), function(response)
				cb(table.unpack(response))
				RemoveEventHandler(event)
			end)
		end
	end
})
