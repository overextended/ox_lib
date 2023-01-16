local dict = {}

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

	return str
end

---@return { [string]: string }
function lib.getLocales()
    return dict
end

function lib.loadLocale()
	local locales = json.decode(LoadResourceFile(cache.resource, ('locales/%s.json'):format(GetConvar('ox:locale', 'en'))) or LoadResourceFile(cache.resource, 'locales/en.json') or '[]')

    for k, v in pairs(locales) do
        if type(v) == 'string' then
            for var in v:gmatch('${[%w%s%p]-}') do
                local locale = locales[var:sub(3, -2)]

                if locale then
                    v = v:gsub(var, locale:gsub('%%', '%%%%'))
                end
            end
        end

        dict[k] = v
    end
end

return lib.loadLocale
