---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@return number? object
---@return vector3? objectCoords
function lib.getClosestObject(coords, maxDistance)
	local objects = GetGamePool('CObject')
	local closestObject, closestCoords
	maxDistance = maxDistance or 2.0

	for i = 1, #objects do
		local object = objects[i]

		local objectCoords = GetEntityCoords(object)
		local distance = #(coords - objectCoords)

		if distance < maxDistance then
			maxDistance = distance
			closestObject = object
			closestCoords = objectCoords
		end
	end

	return closestObject, closestCoords
end

return lib.getClosestObject
