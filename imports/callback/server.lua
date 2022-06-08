local callback = {}
local cbEvent = ('__cb_%s'):format(cache.resource)

---@param name string
---@param cb function
--- Registers an event handler and callback function to respond to client requests.
function callback.register(name, cb)
	name = ('__cb_%s'):format(name)

	RegisterServerEvent(name, function(key, ...)
		TriggerClientEvent(cbEvent, source, key, { cb(source, ...) })
	end)
end

return callback