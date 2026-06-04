---@diagnostic disable: duplicate-set-field

---@private
---@param model string | number
---@param x number
---@param y number
---@param z number
---@param heading? number
---@param isNetworked? boolean
---@param netMissionEntity? boolean
---@return Vehicle
---@see CreateVehicle
---`client`
function lib.vehicle.create(model, x, y, z, heading, isNetworked, netMissionEntity)
    local hash = lib.requestModel(model)
    local handle = CreateVehicle(hash, x, y, z, heading or 0, isNetworked or false, netMissionEntity or false)

    SetModelAsNoLongerNeeded(hash)

    return lib.vehicle:new(handle)
end

return lib.vehicle