local CPlayer = {}
CPlayer.__index = CPlayer

function CPlayer:getCoords()
	if not self.coords then
		self.coords = GetEntityCoords(self.ped)
	end

	return self.coords
end

function CPlayer:getDistance(coords)
	return #(self:getCoords() - coords)
end

function lib.addPlayerMethod(name, fn)
	CPlayer[name] = fn
end

function lib.getPlayer(id, ped, serverId)
	return setmetatable({
		id = id or cache.playerId,
		ped = ped or cache.ped,
		serverId = serverId or cache.serverId,
	}, CPlayer)
end

function lib.getPlayerFromServerId(serverId)
	local playerId = GetPlayerFromServerId(serverId)

	if playerId then
		return lib.getPlayer(playerId, playerId == cache.playerId and cache.ped or NetworkGetEntityFromNetworkId(serverId), serverId)
	end
end

function lib.getPlayerFromPed(ped)
	local playerId = NetworkGetPlayerIndexFromPed(ped)

	if playerId then
		return lib.getPlayer(playerId, ped, playerId == cache.playerId and cache.serverId or GetPlayerServerId(playerId))
	end
end
