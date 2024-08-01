---@class OxCommandParams
---@field name string
---@field help? string
---@field type? 'number' | 'playerId' | 'string' | 'longString'
---@field optional? boolean

---@class OxCommandProperties
---@field help string?
---@field params OxCommandParams[]?
---@field restricted boolean | string | string[]?

---@type OxCommandProperties[]
local registeredCommands = {}
local shouldSendCommands = false

SetTimeout(1000, function()
    shouldSendCommands = true
    TriggerClientEvent('chat:addSuggestions', -1, registeredCommands)
end)

AddEventHandler('playerJoining', function()
    TriggerClientEvent('chat:addSuggestions', source, registeredCommands)
end)

---@param source number
---@param args table
---@param raw string
---@param params OxCommandParams[]?
---@return table?
local function parseArguments(source, args, raw, params)
    if not params then return args end

    local paramsNum = #params
    for i = 1, paramsNum do
        local arg, param = args[i], params[i]
        local value

        if param.type == 'number' then
            value = tonumber(arg)
        elseif param.type == 'string' then
            value = not tonumber(arg) and arg
        elseif param.type == 'playerId' then
            value = arg == 'me' and source or tonumber(arg)

            if not value or not DoesPlayerExist(value--[[@as string]]) then
                value = false
            end
        elseif param.type == 'longString' and i == paramsNum then
            if arg then
                local start = raw:find(arg, 1, true)
                value = start and raw:sub(start)
            else
                value = nil
            end
        else
            value = arg
        end

        if not value and (not param.optional or param.optional and arg) then
            return Citizen.Trace(("^1command '%s' received an invalid %s for argument %s (%s), received '%s'^0\n"):format(string.strsplit(' ', raw) or raw, param.type, i, param.name, arg))
        end

        arg = value

        args[param.name] = arg
        args[i] = nil
    end

    return args
end

---@param commandName string | string[]
---@param properties OxCommandProperties | false
---@param cb fun(source: number, args: table, raw: string)
---@param ... any
function lib.addCommand(commandName, properties, cb, ...)
    -- Try to handle backwards-compatibility with the old addCommand syntax (prior to v3.0)
    local restricted, params

    if properties then
        if ... or table.type(properties) ~= 'hash' then
            local _commandName = type(properties) == 'table' and properties[1] or properties
            local info = debug.getinfo(2, 'Sl')

            warn(("command '%s' is using deprecated syntax for lib.addCommand\nupdate the command or use lib.__addCommand to ignore this warning\n> source ^0(^5%s^0:%d)"):format(_commandName, info.short_src, info.currentline))
            ---@diagnostic disable-next-line: deprecated
            return lib.__addCommand(commandName, properties, cb, ...)
        end

        restricted = properties.restricted
        params = properties.params
    end

    if params then
        for i = 1, #params do
            local param = params[i]

            if param.type then
                param.help = param.help and ('%s (type: %s)'):format(param.help, param.type) or ('(type: %s)'):format(param.type)
            end
        end
    end

    local commands = type(commandName) ~= 'table' and { commandName } or commandName
    local numCommands = #commands
    local totalCommands = #registeredCommands

    local function commandHandler(source, args, raw)
        args = parseArguments(source, args, raw, params)

        if not args then return end

        local success, resp = pcall(cb, source, args, raw)

        if not success then
            Citizen.Trace(("^1command '%s' failed to execute!\n%s"):format(string.strsplit(' ', raw) or raw, resp))
        end
    end

    for i = 1, numCommands do
        totalCommands += 1
        commandName = commands[i]

        RegisterCommand(commandName, commandHandler, restricted and true)

        if restricted then
            local ace = ('command.%s'):format(commandName)
            local restrictedType = type(restricted)

            if restrictedType == 'string' and not IsPrincipalAceAllowed(restricted, ace) then
                lib.addAce(restricted, ace)
            elseif restrictedType == 'table' then
                for j = 1, #restricted do
                    if not IsPrincipalAceAllowed(restricted[j], ace) then
                        lib.addAce(restricted[j], ace)
                    end
                end
            end
        end

        if properties then
            ---@diagnostic disable-next-line: inject-field
            properties.name = ('/%s'):format(commandName)
            properties.restricted = nil
            registeredCommands[totalCommands] = properties

            if i ~= numCommands and numCommands ~= 1 then
                properties = table.clone(properties)
            end

            if shouldSendCommands then TriggerClientEvent('chat:addSuggestions', -1, properties) end
        end
    end
end

return lib.addCommand
