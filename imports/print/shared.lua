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
local function handleException(reason, value)
    if type(value) == 'function' then return tostring(value) end
    return reason
end
local jsonOptions = { sort_keys = true, indent = true, exception = handleException }

---Prints to console conditionally based on what ox:printlevel is.
---Any print with a level more severe will also print. If ox:printlevel is info, then warn and error prints will appear as well, but debug prints will not.
---@param level PrintLevel
---@param ... any
local function libPrint(level, ...)
    if level > resourcePrintLevel then return end

    local args = { ... }

    for i = 1, #args do
        local arg = args[i]
        args[i] = type(arg) == 'table' and json.encode(arg, jsonOptions) or tostring(arg)
    end

    print(template:format(levelPrefixes[level], table.concat(args, '\t')))
end

lib.print = {
    error = function(...) libPrint(printLevel.error, ...) end,
    warn = function(...) libPrint(printLevel.warn, ...) end,
    info = function(...) libPrint(printLevel.info, ...) end,
    verbose = function(...) libPrint(printLevel.verbose, ...) end,
    debug = function(...) libPrint(printLevel.debug, ...) end,
}

return lib.print
