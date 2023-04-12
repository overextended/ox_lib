lib.raycast = {}

local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial
local GetWorldCoordFromScreenCoord = GetWorldCoordFromScreenCoord

---@alias ShapetestIgnore
---| 1 GLASS
---| 2 SEE_THROUGH
---| 3 GLASS | SEE_THROUGH
---| 4 NO_COLLISION
---| 7 GLASS | SEE_THROUGH | NO_COLLISION

---@param flags number? Line of sight flags, defaults to 511 (see: https://docs.fivem.net/natives/?_0x377906D8A31E5586).
---@param ignore ShapetestIgnore? Defaults to 4.
---@param distance number? Defaults to 10.
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
function lib.raycast.cam(flags, ignore, distance)
	local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
	local destination = coords + normal * (distance or 10)
	local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z,
		flags or 511, cache.ped, ignore or 4)

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
