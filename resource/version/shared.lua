function lib.checkDependency(resource, minimumVersion, printMessage)
	local currentVersion = GetResourceMetadata(resource, 'version', 0):match('%d%.%d+%.%d+')

	if currentVersion ~= minimumVersion then
		local cv = { string.strsplit('.', currentVersion) }
		local mv = { string.strsplit('.', minimumVersion) }
		local msg = ("^1%s requires version '%s' of '%s' (current version: %s)^0"):format(GetInvokingResource() or GetCurrentResourceName(), minimumVersion, resource, currentVersion)

		for i = 1, #cv do
            local current, minimum = tonumber(cv[i]), tonumber(mv[i])

            if current ~= minimum then
                if current < minimum then
                    if printMessage then
                        return print(msg)
                    end

                    return false, msg
                else break end
            end
		end
	end

	return true
end
