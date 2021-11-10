local ServerCallback = {
	Register = function(name, callback)
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