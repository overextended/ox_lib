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

-- Color codes for different data types
local printTable_colors <const> = {
    ['string'] = '\27[32m',   -- Green for strings
    ['number'] = '\27[33m',   -- Yellow for numbers
    ['table'] = '\27[34m',    -- Blue for tables
    ['boolean'] = '\27[36m',  -- Cyan for booleans
    ['function'] = '\27[35m', -- Magenta for functions
    ['vector'] = '\27[35m',   -- Magenta for vector
    ['vector2'] = '\27[35m',  -- Magenta for vector2
    ['vector3'] = '\27[35m',  -- Magenta for vector3
    ['vector4'] = '\27[35m',  -- Magenta for vector4
    ['reset'] = '\27[0m'      -- Reset to default console color
}

--- Prints a table with color-coded output for different data types.
-- @param t The table to print.
-- @param indent The current indentation level (used for nested tables).
-- @param visited A table to track visited tables and avoid circular references.
local function printTable(t, indent, visited)
    -- Ensure the input is a table
    assert(type(t) == 'table', 'Expected table, got ' .. type(t))

    -- Initialize visited and indent if not provided
    visited = visited or {}
    indent = indent or ''

    -- Check for and handle circular references
    if visited[t] then
        print(indent .. printTable_colors['table'] .. '<circular reference>' .. printTable_colors['reset'])
        return
    end

    -- Mark the current table as visited
    visited[t] = true

    -- Check if the table is empty
    if next(t) == nil then
        print(indent .. printTable_colors['table'] .. '{}' .. printTable_colors['reset'])
        return
    end

    -- Print the opening bracket for the table
    print(indent .. printTable_colors['table'] .. '{' .. printTable_colors['reset'])

    -- Iterate over table elements
    for key, value in pairs(t) do
        local valueType = type(value)
        local color = printTable_colors[valueType] or printTable_colors['reset']
        local formattedKey = type(key) == 'number' and '[' .. key .. ']' or tostring(key)
        if valueType == 'table' then
            -- For nested tables, print the key and recursively print the table
            print(indent .. '  ' .. printTable_colors['table'] .. formattedKey .. printTable_colors['reset'] .. ':')
            printTable(value, indent .. '    ', visited)
        else
            -- For other types, print the key and value with appropriate coloring
            print(indent .. '  ' .. color .. formattedKey .. ': ' .. tostring(value) .. printTable_colors['reset'])
        end
    end

    -- Print the closing bracket for the table
    print(indent .. printTable_colors['table'] .. '}' .. printTable_colors['reset'])
end

-- lib.print table to hold different logging functions including the enhanced table printing function
lib.print = {
    error = function(...) libPrint(printLevel.error, ...) end,     -- Function to log errors
    warn = function(...) libPrint(printLevel.warn, ...) end,       -- Function to log warnings
    info = function(...) libPrint(printLevel.info, ...) end,       -- Function to log informational messages
    verbose = function(...) libPrint(printLevel.verbose, ...) end, -- Function to log verbose messages
    debug = function(...) libPrint(printLevel.debug, ...) end,     -- Function to log debug messages

    table = printTable,                                            -- Enhanced table printing function with color coding and indentation
}

return lib.print
