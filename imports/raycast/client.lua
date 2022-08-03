---------------------------------------
--- Source: https://github.com/citizenfx/lua/blob/luaglm-dev/cfx/libs/scripts/examples/scripting_gta.lua
--- Credits to gottfriedleibniz
local glm = require 'glm'
local glm_rad = glm.rad
local glm_quatEuler = glm.quatEulerAngleZYX
local glm_rayPicking = glm.rayPicking
local glm_up = glm.up()
local glm_forward = glm.forward()
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetFinalRenderedCamRot = GetFinalRenderedCamRot

local function screenPositionToCameraRay(fov, ratio)
	local rot = glm_rad(GetFinalRenderedCamRot(2))
	local q = glm_quatEuler(rot.z, rot.y, rot.x)
	return GetFinalRenderedCamCoord(), glm_rayPicking(
		q * glm_forward,
		q * glm_up,
		glm_rad(fov or GetFinalRenderedCamFov()),
		ratio or GetAspectRatio(true),
		0.10000, -- GetFinalRenderedCamNearClip(),
		10000.0, -- GetFinalRenderedCamFarClip(),
		0, 0
	)
end

---------------------------------------

local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial
local raycast = {}

---@param fov number? GetFinalRenderedCamFov
---@param ratio number? GetAspectRatio
---@param flag number? Defaults to 1|2|8|16 (see: https://docs.fivem.net/natives/?_0x377906D8A31E5586)
---@return vector3 endCoords
---@return number entityHit
---@return vector3 surfaceNormal
---@return number materialHash
function raycast.cam(fov, ratio, flag)
	local rayPos, rayDir = screenPositionToCameraRay(fov, ratio)
	local destination = rayPos + 10 * rayDir
	local handle = StartShapeTestLosProbe(rayPos.x, rayPos.y, rayPos.z, destination.x, destination.y, destination.z,
		flag or 1 | 2 | 8 | 16, cache.ped, 4)

	while true do
		Wait(0)
		local retval, _, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(handle)

		if retval ~= 1 then
			return entityHit, endCoords, surfaceNormal, materialHash
		end
	end
end

return raycast