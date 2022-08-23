function lib.checkDependency(resource, minimumVersion, printMessage)
	local currentVersion = GetResourceMetadata(resource, 'version', 0):match('%d%.%d+%.%d+')

	if currentVersion ~= minimumVersion then
		local cMajor, cMinor = string.strsplit('.', currentVersion, 2)
		local mMajor, mMinor = string.strsplit('.', minimumVersion, 2)

		local msg = ("^1%s requires version '%s' of '%s' (current version: %s)^0"):format(GetInvokingResource() or GetCurrentResourceName(), minimumVersion, resource, currentVersion)
		if tonumber(cMajor) < tonumber(mMajor) or tonumber(cMinor) < tonumber(mMinor) then
			if printMessage then
				return print(msg)
			end

			return false, msg
		end
	end

	return true
end
