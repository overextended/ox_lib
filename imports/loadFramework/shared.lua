local function ref(framework)
	if framework == 'ox_core' or framework == 'es_extended'then
		return 'imports.lua'
	elseif framework == 'qb-core' then
		return exports['qb-core'].GetCoreObject
	end
end

local function err(e, n)
	error(('^1%s^0'):format(e), n)
end

return function(framework)
	if framework == 'ox' then framework = 'ox_core'
	elseif framework == 'esx' then framework = 'es_extended'
	elseif framework == 'qbcore' then framework = 'qb-core' end

	local result
	local success, import = pcall(ref, framework)

	if not success or not import then
		err(import and import or ('no loader exists for %s'):format(framework), 1)
	end

	if type(import) == 'table' then
		import.resource = framework
		return import
	end

	success, result = pcall(LoadResourceFile, framework, import)

	if not result then
		err(("unable to load '@%s/%s'"):format(framework, import))
	end

	if not success then
		err(result and result or ("unable to load '@%s/%s'"):format(framework, import), 0)
	end

	if success then
		success, result = pcall(load, result, ('@@%s/%s'):format(framework, import), 't')

		if not result then
			-- TODO: catch the error that pcall somehow doesn't catch?
			err(("an unknown error occured while loading '@%s/%s'"):format(framework, import))
		end

		if success then
			success, result = pcall(result)

			if not success then err(result) end
		end
	end

	if framework == 'ox_core' then
		import = Ox
	elseif framework == 'es_extended' then
		import = ESX
	end

	import.resource = framework

	return import
end
