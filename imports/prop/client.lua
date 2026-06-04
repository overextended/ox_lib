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
---@param netMissionEntity? boolean
---@param dynamic? boolean
---@return Prop
---@see CreateObject
---`client`
function lib.prop.create(model, x, y, z, heading, isNetworked, netMissionEntity, dynamic)
    local hash = lib.requestModel(model)
    local handle = CreateObject(hash, x, y, z, isNetworked or false, netMissionEntity or false, dynamic or false)
    local prop = lib.prop:new(handle)

    SetModelAsNoLongerNeeded(hash)

    if heading then prop:setHeading(heading) end

    return prop
end

return lib.prop
