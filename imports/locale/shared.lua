---@type { [string]: string }
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

function lib.getLocales()
    return dict
end

function lib.locale()
    local lang = GetConvar('ox:locale', 'en')
    local locales = json.decode(LoadResourceFile(cache.resource, ('locales/%s.json'):format(lang)))

    if not locales then
        local warning = "could not load 'locales/%s.json'"
        warn(warning:format(lang))

        if lang ~= 'en' then
            locales = json.decode(LoadResourceFile(cache.resource, 'locales/en.json'))

            if not locales then
                warn(warning:format('en'))
            end
        end

        if not locales then return end
    end

    for k, v in pairs(locales) do
        if type(v) == 'string' then
            for var in v:gmatch('${[%w%s%p]-}') do
                local locale = locales[var:sub(3, -2)]

                if locale then
                    locale = locale:gsub('%%', '%%%%')
                    v = v:gsub(var, locale)
                end
            end
        end

        dict[k] = v
    end
end

return lib.locale
