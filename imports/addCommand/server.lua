---@param group string | string[] | false
---@param name string | string[]
---@param callback function
---@param parameters table
---@deprecated Use lib.registerCommand instead
function lib.addCommand(group, name, callback, parameters, help)
	local splitParameters = parameters and {} or nil
	if parameters then
		for i = 1, #parameters do
			local arg, argType = string.strsplit(':', parameters[i])
			local required = true
			if argType and argType:sub(0, 1) == '?' then
				argType = argType:sub(2, #argType)
				required = false
			end
			splitParameters[i] = {
				name = arg,
				type = argType,
				required = required
			}
		end
	end
	lib.registerCommand({
		name = name,
		groups = group,
		params = splitParameters,
		help = help
	}, callback)
end
return lib.addCommand

--[[ Example
	AddCommand('group.admin', {'additem', 'giveitem'}, function(source, args)
		args.item = Items(args.item)
		if args.item and args.count > 0 then
			Inventory.AddItem(args.target, args.item.name, args.count, args.metatype)
		end
	end, {'target:number', 'item:string', 'count:number', 'metatype:?string'})
	-- /additem 1 burger 1
]]
