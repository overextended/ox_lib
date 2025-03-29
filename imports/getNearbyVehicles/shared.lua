--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@param includePlayerVehicle? boolean Whether or not to include the player's current vehicle.
---@return { vehicle: number, coords: vector3 }[]
function lib.getNearbyVehicles(coords, maxDistance, includePlayerVehicle)
	local vehicles = GetGamePool('CVehicle')
	local nearby = {}
	local count = 0
	maxDistance = maxDistance or 2.0

	for i = 1, #vehicles do
		local vehicle = vehicles[i]

		if lib.context == 'server' or not cache.vehicle or vehicle ~= cache.vehicle or includePlayerVehicle then
			local vehicleCoords = GetEntityCoords(vehicle)
			local distance = #(coords - vehicleCoords)

			if distance < maxDistance then
				count += 1
				nearby[count] = {
					vehicle = vehicle,
					coords = vehicleCoords
				}
			end
		end
	end

	return nearby
end

return lib.getNearbyVehicles
