return function()
	local result

	Citizen.CreateThreadNow(function()
		local framework = GetConvar('framework', '')

		if framework == '' then
			framework = GetResourceState('ox_core'):find('start') and 'ox_core'
			or GetResourceState('qb-core'):find('start') and 'qb-core'
			or GetResourceState('es_extended'):find('start') and 'es_extended'

			if not framework then
				error('Unable to determine framework (convar is not set, or resource was renamed)')
			end
		end

		local success, import

		if framework == 'qb-core' then
			import = exports[framework]:GetCoreObject()
		elseif framework == 'es_extended' then
			import = exports[framework]:getSharedObject()
		end

		if import then
			import.resource = framework
		else
			if framework == 'ox_core' then
				import = ('%s/import.lua'):format(lib.service)
			else
				error('no loader exists for %s'):format(framework)
			end

			success, result = pcall(LoadResourceFile, framework, import)

			if not result then
				error(("Unable to load '@%s/%s'"):format(framework, import))
			end

			if not success then
				error(result and result or ("Unable to load '@%s/%s'"):format(framework, import), 0)
			end

			success, result = load(result, ('@@%s/%s'):format(framework, import))

			if not success then
				error(result, 0)
			end

			success, result = pcall(success)

			if not success then error(result) end

			if framework == 'ox_core' then
				import = Ox
			end

			import.resource = framework
		end

		result = import
	end)

	return result
end
