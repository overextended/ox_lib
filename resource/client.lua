local _registerCommand = RegisterCommand

---@param commandName string
---@param callback fun(source, args, raw)
---@param restricted boolean?
function RegisterCommand(commandName, callback, restricted)
	_registerCommand(commandName, function(source, args, raw)
		if not restricted or lib.callback.await('ox_lib:checkPlayerAce', 100, ('command.%s'):format(commandName)) then
			callback(source, args, raw)
		end
	end)
end

RegisterNUICallback('getConfig', function(_, cb)
    cb({
        primaryColor = GetConvar('ox:primaryColor', 'blue'),
        primaryShade = GetConvarInt('ox:primaryShade', 8)
    })
end)
