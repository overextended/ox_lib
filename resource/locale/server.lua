RegisterCommand('serverlocale', function(_, args, _)
	if args?[1] then
		SetResourceKvp('locale', args[1])
		TriggerEvent('ox_lib:setLocale', args[1])
	end
end, true)

function lib.getServerLocale()
	return GetResourceKvpString('locale') or 'en-US'
end
