local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial
local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord

---@param flags number? Defaults to 1|2|8|16 (see: https://docs.fivem.net/natives/?_0x377906D8A31E5586)
---@param p8 number? A bit mask with bits 1, 2, 4, or 7 relating to collider types. 4 and 7 are usually used.
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
function lib.raycast.cam(flags, p8)
	local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
	local destination = coords + normal * 10
	local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z,
		flags or 1 | 2 | 8 | 16, cache.ped, p8 or 4)

	while true do
		Wait(0)
		local retval, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(handle)

		if retval ~= 1 then
            ---@diagnostic disable-next-line: return-type-mismatch
			return hit, entityHit, endCoords, surfaceNormal, materialHash
		end
	end
end

return lib.raycast