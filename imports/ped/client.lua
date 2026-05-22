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
---@param isNetworked? boolean
---@param bScriptHostPed? boolean
---@return Ped
---@see CreatePed
---`client`
function lib.ped.create(model, x, y, z, heading, isNetworked, bScriptHostPed)
    local hash = lib.requestModel(model)
    local handle = CreatePed(0, hash, x, y, z, heading or 0, isNetworked or false, bScriptHostPed or false)

    SetModelAsNoLongerNeeded(hash)

    return lib.ped:new(handle)
end
