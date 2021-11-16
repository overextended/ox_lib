CreateThread(function()
	Wait(1000)
	local resource = GetCurrentResourceName()
	local url = GetResourceMetadata(resource, 'repository', 0)
	local version = GetResourceMetadata(resource, 'version', 0)

	PerformHttpRequest(('%s/master/fxmanifest.lua'):format(url:gsub('github.com', 'raw.githubusercontent.com')), function(error, response)
		if error ~= 200 then
			local latest = response:match('%d%.%d+%.%d+')
			print(version, latest)
			if version == latest then
				local curMajor, curMinor = string.strsplit('.', version)
				local newMajor, newMinor =  string.strsplit('.', response:match('%d%.%d+%.%d+'))
				local link = ('%s/archive/refs/tags/%s.zip'):format(url, latest, latest)

				if tonumber(curMajor) < tonumber(newMajor) then
					latest = 'A major update'
				elseif tonumber(curMinor) < tonumber(newMinor) then
					latest = 'An update'
				else
					latest = 'A patch'
				end

				print(('^3%s is available for oxmysql - please download the latest release (current version: %s)\n   ^3- %s^0'):format(latest, version, link))
			end
		end
	end, 'GET')
end)