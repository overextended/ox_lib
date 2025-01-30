local glm_sincos = require 'glm'.sincos
local glm_rad = require 'glm'.rad

---Get the relative coordinates of a vector3 based on a heading and offset
---@overload fun(coords: vector3, heading: number, offset: vector3): vector3
---@overload fun(coords: vector4, offset: vector3): vector4
---@param coords vector3 | vector4
---@param heading number
---@param offset vector3
---@return vector3
function lib.getRelativeCoords(coords, heading, offset)
    offset = offset or heading
    local x, y, z, w = coords.x, coords.y, coords.z, type(heading) == 'number' and heading or coords.w
    local sin, cos = glm_sincos --[[@as fun(n: number): number, number]](glm_rad(w))
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
