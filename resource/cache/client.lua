local cache = {}
cache.playerId = PlayerId()
cache.serverId = GetPlayerServerId(cache.playerId)

local GetVehiclePedIsUsing = GetVehiclePedIsUsing
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers

function cache:getVehicle()
	local vehicle = GetVehiclePedIsUsing(self.ped)
	if vehicle > 0 then
		self:set('vehicle', vehicle)

		if not cache.seat or GetPedInVehicleSeat(vehicle, cache.seat) ~= cache.ped then
			for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
				if GetPedInVehicleSeat(vehicle, i) == self.ped then
					return self:set('seat', i)
				end
			end
		end
	else
		self:set('vehicle', false)
		self:set('seat', false)
	end
end

function cache:set(key, value)
	if value ~= self[key] then
		self[key] = value
		TriggerEvent(('ox_lib:cache:%s'):format(key), value)
		return true
	end
end

CreateThread(function()
	while true do
		cache:set('ped', PlayerPedId())
		cache:getVehicle()
		Wait(100)
	end
end)

function lib.cache(key)
	return cache[key]
end

_ENV.cache = cache
