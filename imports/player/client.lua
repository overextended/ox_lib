local CPlayer = {}
CPlayer.__index = CPlayer

function CPlayer:getCoords(update)
	if update or not self.coords then
		self.coords = GetEntityCoords(cache.ped)
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
		serverId = cache.serverId,
	}, CPlayer)
end

player = lib.getPlayer()
