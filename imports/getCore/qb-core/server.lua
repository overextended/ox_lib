return function(resource)
	local QBCore = exports[resource]:GetCoreObject()
	-- Eventually add some functions here to simplify the creation of framework-agnostic resources.
	return QBCore
end
