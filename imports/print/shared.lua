---@enum PrintLevel
local printLevel = {
    error = 1,
    warn = 2,
    info = 3,
    verbose = 4,
    debug = 5,
}

local levelPrefixes = {
    '^1[ERROR]',
    '^3[WARN]',
    '^7[INFO]',
    '^4[VERBOSE]',
    '^6[DEBUG]',
}

local resourcePrintLevel = printLevel[GetConvar('ox:printlevel:' .. cache.resource, GetConvar('ox:printlevel', 'info'))]
local template = ('^5[%s] %%s %%s^7'):format(cache.resource)
local jsonOptions = { sort_keys = true, indent = true }

---Prints to console conditionally based on what ox:printlevel is.
---Any print with a level more severe will also print. If ox:printlevel is info, then warn and error prints will appear as well, but debug prints will not.
---@param level PrintLevel
---@param pattern string
---@param ... any
local function libPrint(level, pattern, ...)
    if level > resourcePrintLevel then return end

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
