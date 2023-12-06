---@param coords vector3 The coords to check from.
---@param maxDistance number The max distance to check.
---@param includePlayerVehicle boolean Whether or not to include the player's current vehicle. Ignored on the server.
---@return number? vehicle
---@return vector3? vehicleCoords
function lib.getClosestVehicle(coords, maxDistance, includePlayerVehicle)
	local vehicles = GetGamePool('CVehicle')
	local closestVehicle, closestCoords
	maxDistance = maxDistance or 2.0

	for i = 1, #vehicles do
		local vehicle = vehicles[i]

		if lib.context == 'server' or not cache.vehicle or vehicle ~= cache.vehicle or includePlayerVehicle then
			local vehicleCoords = GetEntityCoords(vehicle)
			local distance = #(coords - vehicleCoords)

			if distance < maxDistance then
				maxDistance = distance
				closestVehicle = vehicle
				closestCoords = vehicleCoords
			end
		end
	end

	return closestVehicle, closestCoords
end

return lib.getClosestVehicle
