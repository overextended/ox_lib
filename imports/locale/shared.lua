---@type { [string]: string }
local dict = {}

---@param prefix string|nil
---@param source { [string]: string }
---@param target { [string]: string }
local function flattenDict(prefix, source, target)
    for key, value in pairs(source) do
        local fullKey = prefix and (prefix .. "." .. key) or key

        if type(value) == "table" then
            flattenDict(fullKey, value, target)
        else
            target[fullKey] = value
        end
    end
end

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

---Loads the ox_lib locale module. Prefer using fxmanifest instead (see [docs](https://overextended.dev/ox_lib#usage)).
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

    local flattenedDict = {}
    flattenDict(nil, locales, flattenedDict)

    for k, v in pairs(flattenedDict) do
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

---Gets a locale string from another resource and adds it to the dict.
---@param resource string
---@param key string
---@return string?
function lib.getLocale(resource, key)
    local locale = dict[key]

    if locale then
        warn(("overwriting existing locale '%s' (%s)"):format(key, locale))
    end

    locale = exports[resource]:getLocale(key)
    dict[key] = locale

    if not locale then
        warn(("no locale exists with key '%s' in resource '%s'"):format(key, resource))
    end

    return locale
end

---Backing function for lib.getLocale.
---@param key string
---@return string?
exports('getLocale', function(key)
    return dict[key]
end)

return lib.locale
