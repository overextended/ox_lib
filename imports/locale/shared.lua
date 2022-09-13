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

function lib.loadLocale(locale)
    if not locale then
        locale = lib.context == 'server' and lib.getServerLocale() or GetExternalKvpString('ox_lib', 'locale') or 'en'
    end

	local resourceName = GetCurrentResourceName()
	local JSON = LoadResourceFile(resourceName, ('locales/%s.json'):format(locale)) or LoadResourceFile(resourceName, ('locales/en.json'):format(locale))
	dict = JSON and json.decode(JSON) or {}
end

AddEventHandler('ox_lib:setLocale', lib.loadLocale)

return lib.loadLocale