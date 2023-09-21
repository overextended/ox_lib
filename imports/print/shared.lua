local printLevelConvar = GetConvar('ox:printlevel', 'info')

local PrintLevel = {
    debug = {
        level = 1,
        prefix = '^6[DEBUG] ',
    },
    info = {
        level = 2,
        prefix = '^7[INFO] ',
    },
    warn = {
        level = 3,
        prefix = '^3[WARN] ',
    },
    error = {
        level = 4,
        prefix = '^1[ERROR] ',
    },
}

---Prints to console conditionally based on what ox:printlevel is.
---Any print with a level more severe will also print. If ox:printlevel is info, then warn and error prints will appear as well, but debug prints will not.
---@param level 'debug' | 'info' | 'warn' | 'error'
---@param message any
function lib.print(level, message)
    local printLevel = PrintLevel[level]
    if printLevel.level < PrintLevel[printLevelConvar].level then return end
    message = type(message) == "string" and message or json.encode(message)

    -- server prints are forwarded to the client from the chat resource, so this lets clients see the original resource.
    local resourceName = IsDuplicityVersion() and '^5[' .. cache.resource .. '] ' or '' 

    print(string.format('^5%s%s%s^1', resourceName, printLevel.prefix, message))
end

return lib.print
