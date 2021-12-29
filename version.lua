CreateThread(function()
	Wait(1000)
	local resource = GetCurrentResourceName()
	local url = GetResourceMetadata(resource, 'repository', 0)
	local version = GetResourceMetadata(resource, 'version', 0)

	PerformHttpRequest(('%s/master/fxmanifest.lua'):format(url:gsub('github.com', 'raw.githubusercontent.com')), function(error, response)
		if error == 200 and response then
			local latest = response:match('%d%.%d+%.%d+')
			if version < latest then
				print(('^3An update is available for pe-lualib - please download the latest release (current version: %s)\n   ^3- %s^0'):format(latest, version, ('%s/archive/refs/tags/%s.zip'):format(url, latest, latest)))
			end
		end
	end, 'GET')
end)