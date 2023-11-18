---@param coords vector3 The coords to check from.
---@param maxDistance number The max distance to check.
---@return number? vehicle
---@return vector3? vehicleCoords
function lib.getClosestVehicle(coords, maxDistance)
    local vehicles = GetAllVehicles()
    local closestVehicle, closestCoords
    maxDistance = maxDistance or 2.0

    for i = 1, #vehicles do
        local vehicle = vehicles[i]

        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(coords - vehicleCoords)

        if distance < maxDistance then
            maxDistance = distance
            closestVehicle = vehicle
            closestCoords = vehicleCoords
        end
    end

    return closestVehicle, closestCoords
end

return lib.getClosestVehicle
