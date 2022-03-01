local cache = {}
local player = LocalPlayer.state
local states = {
	['vehicle'] = true,
	['driver'] = true
}

function cache:set(key, value)
	if value ~= self[key] then
		self[key] = value

		if states[key] then player:set(key, value, false) end
	end
end

function cache:getPed()
	local ped = PlayerPedId()
	if ped ~= self.ped then
		self.ped = ped
	end
end

function cache:getVehicle()
	local vehicle = GetVehiclePedIsIn(self.ped, false)
	if vehicle > 0 then
		if vehicle ~= self.vehicle then
			self:set('vehicle', vehicle)

			if GetPedInVehicleSeat(vehicle, -1) == self.ped then
				self:set('driver', true)
			else
				self:set('driver', false)
			end
		end
	else self:set('vehicle', nil) end
end

function cache:onFoot()
	-- print('on foot')
end

function cache:inVehicle()
	if self.driver then
		-- print('driving vehicle')
	else
		-- print('in vehicle')
	end
end

CreateThread(function()
	while true do
		cache:getPed()
		cache:getVehicle()

		if not cache.vehicle then
			cache:onFoot()
		else
			cache:inVehicle()
		end

		Wait(100)
	end
end)
