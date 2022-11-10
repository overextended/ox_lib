local cache = _ENV.cache
cache.playerId = PlayerId()
cache.serverId = GetPlayerServerId(cache.playerId)

function cache:set(key, value, previousValue)
	if value ~= self[key] then
		self[key] = value
		TriggerEvent(('ox_lib:cache:%s'):format(key), value, previousValue)
		return true
	end
end

local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
local GetCurrentPedWeapon = GetCurrentPedWeapon

CreateThread(function()
	while true do
		local ped = PlayerPedId()
		cache:set('ped', ped, cache.ped)

		local vehicle = GetVehiclePedIsIn(ped, false)

		if vehicle > 0 then
			cache:set('vehicle', vehicle, cache.vehicle)

			if not cache.seat or GetPedInVehicleSeat(vehicle, cache.seat) ~= ped then
				for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
					if GetPedInVehicleSeat(vehicle, i) == ped then
						cache:set('seat', i, cache.seat)
						break
					end
				end
			end
		else
			cache:set('vehicle', false, cache.vehicle)
			cache:set('seat', false, cache.seat)
		end

		local hasWeapon, currentWeapon = GetCurrentPedWeapon(ped, true)

		cache:set('weapon', hasWeapon and currentWeapon or false, cache.weapon)

		Wait(100)
	end
end)

function lib.cache(key)
	return cache[key]
end
