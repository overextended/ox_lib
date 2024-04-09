---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@return number? ped
---@return vector3? pedCoords
function lib.getClosestPed(coords, maxDistance)
	local peds = GetGamePool('CPed')
	local closestPed, closestCoords
	maxDistance = maxDistance or 2.0

	for i = 1, #peds do
		local ped = peds[i]

        if not IsPedAPlayer(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(coords - pedCoords)

            if distance < maxDistance then
                maxDistance = distance
                closestPed = ped
                closestCoords = pedCoords
            end
        end
	end

	return closestPed, closestCoords
end

return lib.getClosestPed
