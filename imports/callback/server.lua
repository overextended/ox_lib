local ServerCallback = {}

---@param name string
---@param callback function
--- Registers an event handler and callback function to respond to client requests.
ServerCallback.Register = function(name, callback)
	name = ('__cb_%s:%s'):format(GetCurrentResourceName(), name)

	RegisterServerEvent(name, function(id, ...)
		TriggerClientEvent(name..id, source, {callback(source, ...)})
	end)
end

return ServerCallback