return function(resource)
	local ESX = exports[resource]:getSharedObject()
	-- Eventually add some functions here to simplify the creation of framework-agnostic resources.
	return ESX
end
