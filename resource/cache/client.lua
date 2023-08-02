local cache = _ENV.cache
cache.playerId = PlayerId()
cache.serverId = GetPlayerServerId(cache.playerId)

function cache:set(key, value)
	if value ~= self[key] then
		self[key] = value
		TriggerEvent(('ox_lib:cache:%s'):format(key), value)
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
		cache:set('ped', ped)

		local vehicle = GetVehiclePedIsIn(ped, false)

		if vehicle > 0 then
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

		cache:set('weapon', hasWeapon and currentWeapon or false)

		Wait(100)
	end
end)



function lib.cache(key)
	return cache[key]
end


---@type table<any, {gameTime: number, value: any}>
local ttlCache = {}

---@param key any uniquely identifies a cached value
---@param func function returns the value to cache
---@param maxStalenessMs number values older than maxStaleness are re-computed. Milliseconds
---@return any
function lib.cache.ttl(key, func, maxStalenessMs)
	local gameTime = GetGameTimer()
	if not ttlCache[key] or ttlCache[key].gameTime + maxStalenessMs < gameTime then
		ttlCache[key].gameTime = gameTime
		ttlCache[key].value = func()
	end
	return ttlCache[key].value
end
