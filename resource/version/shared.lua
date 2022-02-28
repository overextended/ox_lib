function lib.checkDependency(resource, minimumVersion)
	local currentVersion = GetResourceMetadata(resource, 'version', 0):match('%d%.%d+%.%d+')

	if currentVersion < minimumVersion then
		return print(("^1%s requires version '%s' of '%s' (current version: %s)^0"):format(GetInvokingResource() or GetCurrentResourceName(), minimumVersion, resource, currentVersion))
	end

	return true
end
