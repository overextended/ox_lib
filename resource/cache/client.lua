local cache = {}

function cache:getPed()
	local ped = PlayerPedId()
	if ped ~= self.ped then
		self.ped = ped
	end
end

function cache:getVehicle()
	local vehicle = GetVehiclePedIsIn(self.ped, false)
	if vehicle > 0 then
		if self:set('vehicle', vehicle) then
			if GetPedInVehicleSeat(vehicle, -1) == self.ped then
				self:set('driver', true)
			else
				self:set('driver', false)
			end
		end
	else self:set('vehicle', nil) end
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
		cache:getPed()
		cache:getVehicle()

		-- if not cache.vehicle then
		-- 	cache:onFoot()
		-- else
		-- 	cache:inVehicle()
		-- end

		if cache.update then
			TriggerEvent('lualib:updateCache', update)
			table.wipe(update)
		end

		Wait(100)
	end
end)

function lib.cache(key)
	return cache[key]
end