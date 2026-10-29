-- See https://github.com/overextended/cfxlua-require

---@diagnostic disable-next-line: undefined-global
if not package or not runtime then
    load(LoadResourceFile('require', 'init.lua'), '@@require')()
end

-- Provide compatibility for old API
lib.require = require
lib.loadJson = json.load

---@param filePath string
---@param env? table
---@return unknown
---@deprecated
---@see loadfile
---@see dofile
---Loads and runs a Lua file at the given path. Unlike require, the chunk is not cached for future use.
function lib.load(filePath, env)
    return loadfile(filePath, 't', env)()
end

---Module v2 searcher
---@param modName string
table.insert(package.searchers, 1, function(modName)
    local module, matched = modName:gsub('^Ox%.', '@ox_lib.modules.')

    if matched > 0 then
        return function() return require(module) end
    end
end)

require 'Ox.Class'

local SemVer = require 'Ox.SemVer'
local errors = {}

for i = 0, GetNumResourceMetadata(cache.resource, 'fx_dependencie') - 1 do
    local resource, required = string.strsplit(':', GetResourceMetadata(cache.resource, 'fx_dependencie', i), 2)
    local version = SemVer:new(GetResourceMetadata(resource, 'version', 0))
    required = SemVer:new(required)

    if required:compare(version) == 1 then
        local url = GetResourceMetadata(resource, 'repository', 0) or GetResourceMetadata(resource, 'url', 0)
        errors[#errors + 1] = ("- %s: required %s, installed %s%s"):format(
            resource,
            required,
            version,
            url and (' (%s)'):format(url) or ''
        )
    end
end

if #errors > 0 then
    error(([[The following resource dependencies do not meet the required version:
    %s

Please update the listed resources to their required versions and restart.]]):format(table.concat(errors, '\n\t')), 0)
end


return require
