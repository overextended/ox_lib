RegisterCommand('serverlocale', function(_, args, _)
	if args?[1] then
		SetResourceKvp('locale', args[1])
	end
end, true)
