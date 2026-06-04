--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local cache = _ENV.cache
cache.playerId = PlayerId()
cache.serverId = GetPlayerServerId(cache.playerId)

function cache:set(key, value)
	if value ~= self[key] then
		TriggerEvent(('ox_lib:cache:%s'):format(key), value, self[key])
		self[key] = value

		return true
	end
end

local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
local GetMount = GetMount
local IsPedOnMount = IsPedOnMount
local GetCurrentPedWeapon = GetCurrentPedWeapon

CreateThread(function()
	while true do
		local ped = PlayerPedId()

		-- If the player's ped is changed, the ped value may return 0 during the transition. If the value is 0, skip all checks.
		if ped ~= 0 then
			cache:set('ped', ped)

			local vehicle = GetVehiclePedIsIn(ped, false)

			if vehicle > 0 then
				if vehicle ~= cache.vehicle then
					cache:set('seat', false)
				end

				cache:set('vehicle', vehicle)

				if not cache.seat or GetPedInVehicleSeat(vehicle, cache.seat) ~= ped then
					for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
						if GetPedInVehicleSeat(vehicle, i) == ped then
							cache:set('seat', i)
							break
						end
					end
				end
			else
				cache:set('vehicle', false)
				cache:set('seat', false)
			end

			if cache.game == 'redm' then
				local mount = GetMount(ped)
				local onMount = IsPedOnMount(ped)
				cache:set('mount', onMount and mount or false)
			end

			local hasWeapon, currentWeapon = GetCurrentPedWeapon(ped, true)
			cache:set('weapon', (hasWeapon and currentWeapon ~= 0) and currentWeapon or false)
		end

		Wait(100)
	end
end)

function lib.cache(key)
	return cache[key]
end
