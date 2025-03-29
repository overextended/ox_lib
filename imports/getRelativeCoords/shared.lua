--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local glm_sincos = require 'glm'.sincos --[[@as fun(n: number): number, number]]
local glm_rad = require 'glm'.rad --[[@as fun(n: number): number]]

---Get the relative coordinates based on heading/rotation and offset
---@overload fun(coords: vector3, heading: number, offset: vector3): vector3
---@overload fun(coords: vector4, offset: vector3): vector4
---@overload fun(coords: vector3, rotation: vector3, offset: vector3): vector3
function lib.getRelativeCoords(coords, rotation, offset)
    if type(rotation) == 'vector3' and offset then
        local pitch = glm_rad(rotation.x)
        local roll = glm_rad(rotation.y)
        local yaw = glm_rad(rotation.z)

        local sp, cp = glm_sincos(pitch)
        local sr, cr = glm_sincos(roll)
        local sy, cy = glm_sincos(yaw)

        local rotatedX = offset.x * (cy * cr) + offset.y * (cy * sr * sp - sy * cp) + offset.z * (cy * sr * cp + sy * sp)
        local rotatedY = offset.x * (sy * cr) + offset.y * (sy * sr * sp + cy * cp) + offset.z * (sy * sr * cp - cy * sp)
        local rotatedZ = offset.x * (-sr) + offset.y * (cr * sp) + offset.z * (cr * cp)

        return vec3(
            coords.x + rotatedX,
            coords.y + rotatedY,
            coords.z + rotatedZ
        )
    end

    offset = offset or rotation
    local x, y, z, w = coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or coords.w

    local sin, cos = glm_sincos(glm_rad(w))
    local relativeX = offset.x * cos - offset.y * sin
    local relativeY = offset.x * sin + offset.y * cos

    return coords.w and vec4(
        x + relativeX,
        y + relativeY,
        z + offset.z,
        w
    ) or vec3(
        x + relativeX,
        y + relativeY,
        z + offset.z
    )
end

return lib.getRelativeCoords
