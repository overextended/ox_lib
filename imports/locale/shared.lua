--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@type { [string]: string }
local dict = {}

---@param source { [string]: string }
---@param target { [string]: string }
---@param prefix? string
local function flattenDict(source, target, prefix)
    for key, value in pairs(source) do
        local fullKey = prefix and (prefix .. '.' .. key) or key

        if type(value) == 'table' then
            flattenDict(value, target, fullKey)
        else
            target[fullKey] = value
        end
    end

    return target
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

local function loadLocale(key)
    local data = LoadResourceFile(cache.resource, ('locales/%s.json'):format(key))

    if not data then
        warn(("could not load 'locales/%s.json'"):format(key))
    end

    return json.decode(data) or {}
end

local table = lib.table

---Loads the ox_lib locale module. Prefer using fxmanifest instead (see [docs](https://overextended.dev/ox_lib#usage)).
---@param key? string
function lib.locale(key)
    local lang = key or lib.getLocaleKey()
    local locales = loadLocale('en')

    if lang ~= 'en' then
        table.merge(locales, loadLocale(lang))
    end

    table.wipe(dict)

    for k, v in pairs(flattenDict(locales, {})) do
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

AddEventHandler('ox_lib:setLocale', function(key)
    lib.locale(key)
end)

return lib.locale
