-- See https://github.com/overextended/cfxlua-require

if GetResourceState('require') == 'missing' then
    error("Unable to find 'require' resource provider.\nDownload ^3https://github.com/overextended/cfxlua-require^1 to resolve this error.", 0)
end

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

-- Module v2 searcher
table.insert(package.searchers, 1, function(modName)
    if modName:find('^Ox%.') then
        modName = modName:gsub('^Ox.', '@ox_lib.modules.')
        return function() return require(modName) end
    end
end)
