--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local loaded = {}
local _require = require

package = {
    path = './?.lua;./?/init.lua',
    preload = {},
    loaded = setmetatable({}, {
        __index = loaded,
        __newindex = noop,
        __metatable = false,
    })
}

---@param modName string
---@return string
---@return string
local function getModuleInfo(modName)
    local resource = modName:match('^@(.-)/.+') --[[@as string?]]

    if resource then
        return resource, modName:sub(#resource + 3)
    end

    local idx = 4 -- call stack depth (kept slightly lower than expected depth "just in case")

    while true do
        local src = debug.getinfo(idx, 'S')?.source

        if not src then
            return cache.resource, modName
        end

        resource = src:match('^@@([^/]+)/.+')

        if resource and not src:find('^@@ox_lib/imports/require') then
            return resource, modName
        end

        idx += 1
    end
end

local tempData = {}

---@param name string
---@param path string
---@return string? filename
---@return string? errmsg
---@diagnostic disable-next-line: duplicate-set-field
function package.searchpath(name, path)
    local resource, modName = getModuleInfo(name:gsub('%.', '/'))
    local tried = {}

    for template in path:gmatch('[^;]+') do
        local fileName = template:gsub('^%./', ''):gsub('?', modName:gsub('%.', '/') or modName)
        local file = LoadResourceFile(resource, fileName)

        if file then
            tempData[1] = file
            tempData[2] = resource
            return fileName
        end

        tried[#tried + 1] = ("no file '@%s/%s'"):format(resource, fileName)
    end

    return nil, table.concat(tried, "\n\t")
end

---Attempts to load a module at the given path relative to the resource root directory.\
---Returns a function to load the module chunk, or a string containing all tested paths.
---@param modName string
---@param env? table
local function loadModule(modName, env)
    local fileName, err = package.searchpath(modName, package.path)

    if fileName then
        local file = tempData[1]
        local resource = tempData[2]

        table.wipe(tempData)
        return assert(load(file, ('@@%s/%s'):format(resource, fileName), 't', env or _ENV))
    end

    return nil, err or 'unknown error'
end

---@alias PackageSearcher
---| fun(modName: string): function loader
---| fun(modName: string): nil, string errmsg

local relativeCache = {}

---@param modName string
local function relativeSearcher(modName)
    if modName:sub(1, 2) ~= './' and modName:sub(1, 3) ~= '../' then
        return nil, 'not a relative path'
    end

    local src
    local i = 3

    while true do
        local info = debug.getinfo(i, 'S')
        if not info then break end

        local source = info.source

        if source and source:sub(1, 1) == '@' and not source:find('^@+ox_lib/imports/require/') then
            src = source
            break
        end

        i += 1
    end

    if not src then
        return nil, ("cannot resolve relative path '%s' without a file source"):format(modName)
    end

    local resource = src:match('^@+([^/]+)/') or cache.resource
    local dir = src:match('^@+[^/]+/(.+)/[^/]+%.lua$') or ''
    local parts = {}

    for part in dir:gmatch('[^/]+') do
        parts[#parts + 1] = part
    end

    local rest = modName

    while true do
        if rest:sub(1, 3) == '../' then
            if #parts == 0 then
                return nil, ("relative path '%s' goes above the resource root"):format(modName)
            end
            parts[#parts] = nil
            rest = rest:sub(4)
        elseif rest:sub(1, 2) == './' then
            rest = rest:sub(3)
        else
            break
        end
    end

    rest = rest:gsub('%.lua$', '')

    if rest == '' then
        return nil, ("relative path '%s' resolves to no module"):format(modName)
    end

    local prefix = #parts > 0 and (table.concat(parts, '/') .. '/') or ''
    local relativePath = rest:gsub('%.', '/')
    local cacheKey = ('%s/%s%s'):format(resource, prefix, relativePath)
    local cached = relativeCache[cacheKey]

    if cached ~= nil then
        if cached == '__loading' then
            error(("^1circular-dependency occurred when loading module '%s'^0"):format(modName), 3)
        end

        return function() return cached end
    end

    local fileName = prefix .. relativePath .. '.lua'
    local file = LoadResourceFile(resource, fileName)

    if not file then
        local initPath = prefix .. relativePath .. '/init.lua'
        file = LoadResourceFile(resource, initPath)

        if not file then
            return nil, ("no file '@%s/%s'\n\tno file '@%s/%s'"):format(resource, fileName, resource, initPath)
        end

        fileName = initPath
    end

    local chunk = assert(load(file, ('@@%s/%s'):format(resource, fileName), 't'))

    return function()
        relativeCache[cacheKey] = '__loading'
        local result = chunk()
        if result == nil then result = true end
        relativeCache[cacheKey] = result
        return result
    end
end

---@type PackageSearcher[]
package.searchers = {
    relativeSearcher,
    function(modName)
        local ok, result = pcall(_require, modName)

        if ok then return result end

        return ok, result
    end,
    function(modName)
        if package.preload[modName] ~= nil then
            return package.preload[modName]
        end

        return nil, ("no field package.preload['%s']"):format(modName)
    end,
    function(modName) return loadModule(modName) end,
}

---@param filePath string
---@param env? table
---@return unknown
---Loads and runs a Lua file at the given path. Unlike require, the chunk is not cached for future use.
function lib.load(filePath, env)
    if type(filePath) ~= 'string' then
        error(("file path must be a string (received '%s')"):format(filePath), 2)
    end

    local result, err = loadModule(filePath, env)

    if result then return result() end

    error(("file '%s' not found\n\t%s"):format(filePath, err))
end

---@param filePath string
---@return table
---Loads and decodes a json file at the given path.
function lib.loadJson(filePath)
    if type(filePath) ~= 'string' then
        error(("file path must be a string (received '%s')"):format(filePath), 2)
    end

    local resourceSrc, modPath = getModuleInfo(filePath:gsub('%.', '/'))
    local resourceFile = LoadResourceFile(resourceSrc, ('%s.json'):format(modPath))

    if resourceFile then
        return json.decode(resourceFile)
    end

    error(("json file '%s' not found\n\tno file '@%s/%s.json'"):format(filePath, resourceSrc, modPath))
end

---Loads the given module, returns any value returned by the seacher (`true` when `nil`).\
---Passing `@resourceName.modName` loads a module from a remote resource.
---@param modName string
---@return unknown
function lib.require(modName)
    if type(modName) ~= 'string' then
        error(("module name must be a string (received '%s')"):format(modName), 3)
    end

    local isRelative = modName:sub(1, 2) == './' or modName:sub(1, 3) == '../'

    if not isRelative then
        local module = loaded[modName]

        if module == '__loading' then
            error(("^1circular-dependency occurred when loading module '%s'^0"):format(modName), 2)
        end

        if module ~= nil then return module end

        loaded[modName] = '__loading'
    end

    local err = {}

    for i = 1, #package.searchers do
        local result, errMsg = package.searchers[i](modName)

        if result then
            if type(result) == 'function' then result = result() end

            if not isRelative then
                loaded[modName] = result or result == nil
            end

            return result or result == nil
        end

        err[#err + 1] = errMsg
    end

    error(("%s"):format(table.concat(err, "\n\t")))
end

return lib.require
