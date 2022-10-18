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
    local locale = GetConvar('ox:locale', 'en')
	local JSON = LoadResourceFile(cache.resource, ('locales/%s.json'):format(locale)) or LoadResourceFile(cache.resource, ('locales/en.json'):format(locale))
	dict = JSON and json.decode(JSON) or {}
end

return lib.loadLocale
