local CPlayer = {}
CPlayer.__index = CPlayer

function CPlayer:getCoords(update)
	if update or not self.coords then
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

function lib.getPlayer()
	return setmetatable({
		id = cache.playerId,
		ped = cache.ped,
		serverId = cache.serverId,
	}, CPlayer)
end
