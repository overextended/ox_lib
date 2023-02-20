local commands = {}

---@class Param
---@field name string
---@field help? string
---@field type string
---@field required? boolean

---@class CommandData
---@field name string | string[]
---@field help? string
---@field params? Param[]
---@field groups? string | string[]

SetTimeout(1000, function()
    TriggerClientEvent('chat:addSuggestions', -1, commands)
end)

AddEventHandler('playerJoining', function(source)
    TriggerClientEvent('chat:addSuggestions', source, commands)
end)

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local function chatSuggestions(name, parameters, help)
    local params = {}

    if parameters then
        for i = 1, #parameters do
            local paramater = parameters[i]

            local paramHelp = ''
            if paramater.help and paramater.type then
                paramHelp = ('%s (%s)'):format(paramater.help, firstToUpper(paramater.type))
            elseif paramater.help then
                paramHelp = paramater.help
            elseif paramater.type then
                paramHelp = firstToUpper(paramater.type)
            end

            params[i] = {
                name = paramater.name,
                help = paramHelp
            }
        end
    end

    commands[#commands + 1] = {
        name = '/' .. name,
        help = help,
        params = params
    }
end

---@param data CommandData
---@param callback function
function lib.registerCommand(data, callback)
    if not data.groups then data.groups = 'builtin.everyone' end
    if type(data.name) == "table" then
        for i = 1, #data.name do
            lib.registerCommand({
                name = data.name[i],
                help = data.help,
                params = data.params,
                groups = data.groups
            }, callback)
        end
    else
        chatSuggestions(data.name, data.params, data.help)

        RegisterCommand(data.name, function(source, args, raw)
            source = tonumber(source) --[[@as number]]

            if data.params then
                for i = 1, #data.params do
                    local currParam = data.params[i]
                    local arg, argType = currParam.name, currParam.type
                    local value = args[i]

                    if arg == 'target' and value == 'me' then value = source end

                    if argType and argType ~= '' then
                        if argType == 'number' then
                            value = tonumber(value) or value
                        end

                        local type = type(value)

                        if data.required and type ~= argType then
                            local invalid = ('^1%s expected <%s> for argument %s (%s), received %s^0'):format(data.name,
                                argType, i, arg, type)
                            if source < 1 then
                                return print(invalid)
                            else
                                return TriggerClientEvent('chat:addMessage', source, invalid)
                            end
                        end
                    end

                    args[arg] = value
                    args[i] = nil
                end
            end

            callback(source, args, raw)
        end, data.groups and true)

        data.name = ('command.%s'):format(data.name)
        if type(data.groups) == 'table' then
            for _, v in ipairs(data.groups) do
                if not IsPrincipalAceAllowed(v, data.name) then lib.addAce(v, data.name) end
            end
        else
            if not IsPrincipalAceAllowed(data.groups, data.name) then lib.addAce(data.groups, data.name) end
        end
    end
end

return lib.registerCommand

--[[ example
lib.registerCommand({
    name = {'testshit', 'testshit2'},
    help = "Give an item to a player",
    groups = {'admin', 'moderator'},
    params = {
        {
            name = "target",
            help = "Server ID",
            type = "number",
            required = true
        },
        {
            name = "item",
            help = "Name of the item to give",
            type = "string",
            required = true
        },
        {
            name = "count",
            help = "Amount of the item to give, leave blank for 1",
            type = "number",
            required = false
        },
        {
            name = "metatype",
            help = "Metatype of the item",
            type = "string",
            required = false
        }
    },
}, function(source, args)
    args.item = Items(args.item)
    if args.item and args.count > 0 then
        Inventory.AddItem(args.target, args.item.name, args.count, args.metatype)
    end
end)
]]
