function lib.versionCheck(repository)
	SetTimeout(1000, function()
		local resource = repository:sub(repository:find('/') + 1, #repository)

		PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(repository), function(status, response)
			if status ~= 200 then return end

			response = json.decode(response)
			if response.prerelease then return end

			local currentVersion = GetResourceMetadata(resource, 'version', 0):match('%d%.%d+%.%d+')
			if not currentVersion then return end

			local latestVersion = response.tag_name:match('%d%.%d+%.%d+')
			if not latestVersion then return end

			print(currentVersion, latestVersion)

			if currentVersion >= latestVersion then return end

			print(('^3An update is available for %s (current version: %s)\r\n%s^0'):format(resource, currentVersion, response.html_url))
		end, 'GET')
	end)
end

function lib.checkDependency(resource, minimumVersion)
	local currentVersion = GetResourceMetadata(resource, 'version', 0):match('%d%.%d+%.%d+')

	if currentVersion < minimumVersion then
		return print(("^1%s requires version '%s' of '%s' (current version: %s)^0"):format(GetInvokingResource() or GetCurrentResourceName(), minimumVersion, resource, currentVersion))
	end

	return true
end

lib.versionCheck('overextended/ox_lib')
