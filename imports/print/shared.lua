---@enum PrintLevel
local printLevel = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
}

local levelPrefixes = {
    [1] = '^6[DEBUG]',
    [2] = '^7[INFO]',
    [3] = '^3[WARN]',
    [4] = '^1[ERROR]',
}

---@alias PrintLevelLabel 'debug' | 'info' | 'warn' | 'error'

---@type PrintLevelLabel
local globalPrintLevel = GetConvar('ox:printlevel', 'info')

---@type PrintLevelLabel
local resourcePrintLevelConvar = GetConvar('ox:printlevel:' .. cache.resource, globalPrintLevel)
local resourcePrintLevel = printLevel[resourcePrintLevelConvar]

local template = ('^5[%s] %s %s^1'):format(cache.resource)
local jsonOptions = {sort_keys = true, indent = true}

---Prints to console conditionally based on what ox:printlevel is.
---Any print with a level more severe will also print. If ox:printlevel is info, then warn and error prints will appear as well, but debug prints will not.
---@param level PrintLevel
---@param pattern string
---@param ... any
local function libPrint(level, pattern, ...)
    if level < resourcePrintLevel then return end

    local formattedArgs = {}
    for i = 1,select('#', ...) do
        local arg = select(i, ...)
        arg = type(arg) == 'table' and json.encode(arg, jsonOptions) or tostring(arg)
        formattedArgs[#formattedArgs+1] = arg
    end

    local message = pattern:format(table.unpack(formattedArgs))
    print(template:format(levelPrefixes[level], message))
end

lib.print = {
    debug = function(pattern, ...) libPrint(printLevel.debug, pattern, ...) end,
    info = function(pattern, ...) libPrint(printLevel.info, pattern, ...) end,
    warn = function(pattern, ...) libPrint(printLevel.warn, pattern, ...) end,
    error = function(pattern, ...) libPrint(printLevel.error, pattern, ...) end,
}

return lib.print
