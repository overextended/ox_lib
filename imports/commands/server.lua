---@param group string
---@param name string
---@param callback function
---@param arguments string
local function AddCommand(group, name, callback, arguments)
	if type(name) == 'table' then
		for i=1, #name do
			AddCommand(group, name[i], callback, arguments)
		end
	else
		if not group then group = 'builtin.everyone' end

		RegisterCommand(name, function(source, args)
			if arguments then
				for i=1, #arguments do
					local arg, argType = string.strsplit(':', arguments[i])
					local value = args[i]

					if arg == 'target' and value == 'me' then value = source end

					if argType then
						if argType == 'number' then value = tonumber(value) end
						assert(type(value) == argType or argType:find('?'), ('%s expected <%s> for argument %s (%s), received %s'):format(name, argType, i, arg, type(value)))
					end

					args[arg] = value
					args[i] = nil
				end
			end
			callback(tonumber(source), args)
		end, group and true)

		name = ('command.%s'):format(name)
		if not IsPrincipalAceAllowed(group, name) then ExecuteCommand(('add_ace %s %s allow'):format(group, name)) end
	end
end

return AddCommand

--[[ Example
    AddCommand('admin', {'additem', 'giveitem'}, function(source, args)
        args.item = Items(args.item)
        if args.item and args.count > 0 then
            Inventory.AddItem(args.target, args.item.name, args.count, args.metatype)
        end
    end, {'target:number', 'item:string', 'count:number', 'metatype:?string'})
    -- /additem 1 burger 1
]]