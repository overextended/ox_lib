lib.raycast = {}

local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial
local glm_sincos = require 'glm'.sincos
local glm_rad = require 'glm'.rad
local math_abs = math.abs
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetFinalRenderedCamRot = GetFinalRenderedCamRot

local function getForwardVector()
    local sin, cos = glm_sincos(glm_rad(GetFinalRenderedCamRot(2)))
    return vec3(-sin.z * math_abs(cos.x), cos.z * math_abs(cos.x), sin.x)
end

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
    local camCoords = GetFinalRenderedCamCoord()
    local destination = camCoords + getForwardVector() * (distance or 10)
    local handle = StartShapeTestLosProbe(camCoords.x, camCoords.y, camCoords.z, destination.x, destination.y,
        destination.z, flags or 511, cache.ped, ignore or 4)

    while true do
        Wait(0)
        local retval, hit, coords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(handle)

        if retval ~= 1 then
            return hit, entityHit, coords, surfaceNormal, materialHash
        end
    end
end

return lib.raycast
