local cache = {}

function cache:getVehicle()
	local vehicle = GetVehiclePedIsIn(self.ped, false)
	if vehicle > 0 then
		if self:set('vehicle', vehicle) then
			local seats = GetVehicleMaxNumberOfPassengers(vehicle) - 1
			local GetPedInVehicleSeat = GetPedInVehicleSeat
			for i = -1, seats do
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

function cache:onFoot()
	-- todo
	-- print('on foot')
end

function cache:inVehicle()
	-- todo
	if self.driver then
		-- print('driving vehicle')
	else
		-- print('in vehicle')
	end
end

local update = {}

function cache:set(key, value)
	if value ~= self[key] then
		self[key] = value
		update[key] = value
		return true
	end
end

CreateThread(function()
	while true do
		cache:set('ped', PlayerPedId())
		cache:getVehicle()

		-- if not cache.vehicle then
		-- 	cache:onFoot()
		-- else
		-- 	cache:inVehicle()
		-- end

		if next(update) then
			TriggerEvent('lualib:updateCache', update)
			table.wipe(update)
		end

		Wait(100)
	end
end)

function lib.cache(key)
	return cache[key]
end