local dict

function locale(str, ...)
	local lstr = dict[str]

	if lstr then
		if ... then
			return lstr and lstr:format(...)
		end

		return lstr
	end

	return ("Translation for '%s' does not exist"):format(str)
end

local function loadLocale(locale)
	local resourceName = GetCurrentResourceName()
	local JSON = LoadResourceFile(resourceName, ('locales/%s.json'):format(locale)) or LoadResourceFile(resourceName, ('locales/en-US.json'):format(locale))

	if JSON then
		dict = json.decode(JSON)
	end
end

AddEventHandler('ox_lib:setLocale', loadLocale)

return function()
	loadLocale(GetExternalKvpString('ox_lib', 'locale') or 'en-US')
end
