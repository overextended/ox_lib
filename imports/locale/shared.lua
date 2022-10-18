local dict

---@param str string
---@param ... string | number
---@return string
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

---@return { [string]: string }
function lib.getLocales()
    return dict
end

function lib.loadLocale()
	local JSON = LoadResourceFile(cache.resource, ('locales/%s.json'):format(GetConvar('ox:locale', 'en'))) or LoadResourceFile(cache.resource, 'locales/en.json')
	dict = JSON and json.decode(JSON) or {}
end

return lib.loadLocale
