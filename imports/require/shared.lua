--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local loaded = {}
local moduleEnvs = {}
local _require = require

local defaultEnv = setmetatable({
    print = print,
    pairs = pairs,
    ipairs = ipairs,
    string = string,
    table = table,
    math = math,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    error = error,
    assert = assert,
    next = next,
    json = json,
    exports = exports,
    TriggerEvent = TriggerEvent,
    TriggerServerEvent = TriggerServerEvent,
    RegisterNetEvent = RegisterNetEvent,
    AddEventHandler = AddEventHandler
}, { __index = _G })

package = {
    path = './?.lua;./?/init.lua',
    preload = {},
    loaded = setmetatable({}, {
        __index = loaded,
        __newindex = function() end,
        __metatable = false,
    })
}

---@param modName string
---@return string resource, string modulePath
local function getModuleInfo(modName)
    local resource = modName:match('^@(.-)/.+')
    if resource then
        return resource, modName:sub(#resource + 3)
    end

    local idx = 4
    while true do
        local src = debug.getinfo(idx, 'S')?.source
        if not src then return 'unknown', modName end

        resource = src:match('^@@([^/]+)/.+')
        if resource and not src:find('^@@ox_lib/imports/require') then
            return resource, modName
        end

        idx += 1
    end
end

local tempData = {}

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

package.searchers = {
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

function lib.load(filePath, env)
    if type(filePath) ~= 'string' then
        error(("file path must be a string (received '%s')"):format(filePath), 2)
    end

    local result, err = loadModule(filePath, env)
    if result then return result() end

    error(("file '%s' not found\n\t%s"):format(filePath, err))
end

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

function lib.require(modName)
    if type(modName) ~= 'string' then
        error(("module name must be a string (received '%s')"):format(modName), 3)
    end

    local module = loaded[modName]
    if module == '__loading' then
        error(("^1circular-dependency occurred when loading module '%s'^0"):format(modName), 2)
    end
    if module ~= nil then return module end

    loaded[modName] = '__loading'
    local err = {}

    for i = 1, #package.searchers do
        local result, errMsg = package.searchers[i](modName)

        if result then
            if type(result) == 'function' then
                local env = setmetatable({}, { __index = defaultEnv })
                moduleEnvs[modName] = env
                result = result()
            end

            if type(result) == 'table' and result.depends then
                for _, dep in ipairs(result.depends) do
                    lib.require(dep)
                end
                if result.init then result = result.init() end
            end

            loaded[modName] = result or result == nil
            print(('^2[lib.require+] Loaded:^0 %s'):format(modName))
            return loaded[modName]
        end

        err[#err + 1] = errMsg
    end

    error(("%s"):format(table.concat(err, "\n\t")))
end

function lib.reload(modName)
    if type(modName) ~= 'string' then
        error(("module name must be a string (received '%s')"):format(modName), 2)
    end

    loaded[modName] = nil
    moduleEnvs[modName] = nil
    return lib.require(modName)
end

function lib.reloadAll()
    for modName in pairs(loaded) do
        if loaded[modName] ~= '__loading' then
            lib.reload(modName)
        end
    end
end

function lib.runTests()
    for modName, mod in pairs(loaded) do
        if type(mod) == 'table' and mod.test then
            print(('🧪 Testing module: %s'):format(modName))
            pcall(mod.test)
        end
    end
end

return lib
