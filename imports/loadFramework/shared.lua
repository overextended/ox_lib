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

return function()
	local framework = GetResourceState('ox_core'):find('start') and 'ox_core'

	if not framework then
		framework = GetResourceState('es_extended'):find('start') and 'es_extended'
	end

	if not framework then
		framework = GetResourceState('qb-core'):find('start') and 'qb-core'
	end

	local result
	local success, import = pcall(ref, framework)

	if not success or not import then
		err(import and import or ('no loader exists for %s'):format(framework), 1)
	end

	-- Return early since framework does not use an imports file
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

	success, result = load(result, ('@@%s/%s'):format(framework, import))

	if not success then
		err(result, 0)
	end

	success, result = pcall(success)

	if not success then err(result) end

	if framework == 'ox_core' then
		import = Ox
	elseif framework == 'es_extended' then
		import = ESX
	end

	import.resource = framework

	return import
end
