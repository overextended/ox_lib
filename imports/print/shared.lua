local printLevelConvar = GetConvar('ox:printlevel', 'info')

local printLevels = {
    debug = {
        level = 1,
        prefix = '^6[DEBUG]',
    },
    info = {
        level = 2,
        prefix = '^7[INFO]',
    },
    warn = {
        level = 3,
        prefix = '^3[WARN]',
    },
    error = {
        level = 4,
        prefix = '^1[ERROR]',
    },
}

local template = ('^5[%s] %s %s^1')
local jsonOptions = {sort_keys = true, indent = true}

---Prints to console conditionally based on what ox:printlevel is.
---Any print with a level more severe will also print. If ox:printlevel is info, then warn and error prints will appear as well, but debug prints will not.
---@param level 'debug' | 'info' | 'warn' | 'error'
---@param pattern string
---@param ... any
local function libPrint(level, pattern, ...)
    local printLevel = printLevels[level]
    if printLevel.level < printLevels[printLevelConvar].level then return end

    local formattedArgs = {}
    for i = 1,select('#', ...) do
        local arg = select(i, ...)
        arg = type(arg) == 'table' and json.encode(arg, jsonOptions) or tostring(arg)
        formattedArgs[#formattedArgs+1] = arg
    end

    local message = pattern:format(table.unpack(formattedArgs))
    print(template:format(cache.resource, printLevel.prefix, message))
end

lib.print = {
    debug = function(pattern, ...) libPrint('debug', pattern, ...) end,
    info = function(pattern, ...) libPrint('info', pattern, ...) end,
    warn = function(pattern, ...) libPrint('warn', pattern, ...) end,
    error = function(pattern, ...) libPrint('error', pattern, ...) end,
}

return lib.print
