if not lib.player then lib.player() end

return function(resource)
	local ESX = exports[resource]:getSharedObject()
	-- Eventually add some functions here to simplify the creation of framework-agnostic resources.

	local CPlayer = lib.getPlayer()

	function lib.getPlayer(player)
		player = type(player) == 'table' and player.playerId or ESX.GetPlayerFromId(player)

		if not player then
			error(("'%s' is not a valid player"):format(player))
		end

		return setmetatable(player, CPlayer)
	end

	return ESX
end
