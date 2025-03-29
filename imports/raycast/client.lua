--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

lib.raycast = {}

local StartShapeTestLosProbe = StartShapeTestLosProbe
local GetShapeTestResultIncludingMaterial = GetShapeTestResultIncludingMaterial
local glm_sincos = require 'glm'.sincos
local glm_rad = require 'glm'.rad
local math_abs = math.abs
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetFinalRenderedCamRot = GetFinalRenderedCamRot

---@alias ShapetestIgnore
---| 1 GLASS
---| 2 SEE_THROUGH
---| 3 GLASS | SEE_THROUGH
---| 4 NO_COLLISION
---| 7 GLASS | SEE_THROUGH | NO_COLLISION

---@alias ShapetestFlags integer
---| 1 INCLUDE_MOVER
---| 2 INCLUDE_VEHICLE
---| 4 INCLUDE_PED
---| 8 INCLUDE_RAGDOLL
---| 16 INCLUDE_OBJECT
---| 32 INCLUDE_PICKUP
---| 64 INCLUDE_GLASS
---| 128 INCLUDE_RIVER
---| 256 INCLUDE_FOLIAGE
---| 511 INCLUDE_ALL

---@param coords vector3
---@param destination vector3
---@param flags ShapetestFlags? Defaults to 511.
---@param ignore ShapetestIgnore? Defaults to 4.
---@return boolean hit
---@return number entityHit
---@return vector3 endCoords
---@return vector3 surfaceNormal
---@return number materialHash
function lib.raycast.fromCoords(coords, destination, flags, ignore)
    local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y,
        destination.z, flags or 511, cache.ped, ignore or 4)

    while true do
        Wait(0)
        local retval, hit, endCoords, surfaceNormal, material, entityHit = GetShapeTestResultIncludingMaterial(handle)

        if retval ~= 1 then
            return hit, entityHit, endCoords, surfaceNormal, material
        end
    end
end

local function getForwardVector()
    local sin, cos = glm_sincos(glm_rad(GetFinalRenderedCamRot(2)))
    return vec3(-sin.z * math_abs(cos.x), cos.z * math_abs(cos.x), sin.x)
end

---@param flags ShapetestFlags? Defaults to 511.
---@param ignore ShapetestIgnore? Defaults to 4.
---@param distance number? Defaults to 10.
function lib.raycast.fromCamera(flags, ignore, distance)
    local coords = GetFinalRenderedCamCoord()
    local destination = coords + getForwardVector() * (distance or 10)

    return lib.raycast.fromCoords(GetFinalRenderedCamCoord(), destination, flags, ignore)
end

---@deprecated
lib.raycast.cam = lib.raycast.fromCamera

return lib.raycast
