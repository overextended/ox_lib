--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@diagnostic disable: duplicate-set-field

---@private
---@param model string | number
---@param x number
---@param y number
---@param z number
---@param heading? number
---@return Ped
---@see CreatePed
---`server`
function lib.ped.create(model, x, y, z, heading)
    local handle = CreatePed(0, model, x, y, z, heading or 0, true, true)

    return lib.ped:new(handle)
end

return lib.ped