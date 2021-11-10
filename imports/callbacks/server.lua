local ServerCallback = {}

	---@param name string
	---@param callback function
	--- Registers an event handler and callback function to respond to client requests.
	ServerCallback.Register = function(name, callback)
		name = ('__cb_%s:%s'):format(GetCurrentResourceName(), name)

		RegisterServerEvent(name, function(...)
			local source = source
			callback(source, function(...)
				TriggerClientEvent(name, source, ...)
			end, ...)
		end)
	end
}

return ServerCallback